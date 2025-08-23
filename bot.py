#!/usr/bin/env python3
"""
Telegram bot for extracting lecture and DPP video links from specially
formatted batch or text files. The bot reads a provided file, parses
out subjects, chapters and associated media links, and allows the user
to choose which subjects to extract. Once selected, the bot produces
plain‑text files containing just the lecture and DPP video links for
each subject. If all subjects are selected, it also generates a
modal‑style HTML document listing class notes and DPP notes.

Key features:
* Shows an "inspecting" message during file analysis.
* Lets you select individual subjects or toggle all with a single button.
* Provides dynamic “Select/Unselect All” button behavior.
* Displays clean logging (silences HTTP noise).
* Sends .txt files with subject and link counts, and automatically
  deletes temporary files after sending.
* When all subjects are selected, generates an HTML notes file named
  after the batch (e.g. `BatchName.html`) and sends it to the user.

Requires python‑telegram‑bot >= 20.  Set `TOKEN` to your bot token and add
your user IDs to `AUTHORIZED_USERS` for access control.
"""

import logging
import os
import re
import html
import json
import asyncio
from collections import defaultdict
from pathlib import Path
from typing import Dict, Iterable, List, Tuple

from telegram import (
    InlineKeyboardButton,
    InlineKeyboardMarkup,
    Update,
)
from telegram.constants import ParseMode
from telegram.ext import (
    ApplicationBuilder,
    CallbackQueryHandler,
    CommandHandler,
    ContextTypes,
    MessageHandler,
    filters,
)

# Configuration
TOKEN = ""
AUTHORIZED_USERS = {
    7875474866,
    1955134660,
    1429154571,
    7073085399,
    8199712050  # Replace with your numeric Telegram user IDs
}

# Logging configuration
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)

# Silence external library logs
for lib_name in ["httpx", "telegram.ext", "telegram.ext.application", "telegram.Application"]:
    logging.getLogger(lib_name).setLevel(logging.WARNING)
    logging.getLogger(lib_name).propagate = False
logging.getLogger("httpcore").setLevel(logging.WARNING)
logging.getLogger("httpcore").propagate = False

# ----------- Helper functions for lectures/DPP extraction -----------

def remove_ansi(line: str) -> str:
    return re.sub(r"!ESC!\[[0-9;]+m", "", line)

def parse_file(path: Path) -> Dict[str, Dict[str, Dict[str, List[Tuple[str, str]]]]]:
    try:
        text = path.read_text(errors="ignore")
    except FileNotFoundError:
        raise FileNotFoundError(f"File not found: {path}")

    data = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    current_subject = None
    current_chapter = None
    last_lecture_name = None
    last_note_name = None
    last_dpp_video_name = None
    last_dpp_note_name = None

    subject_pattern = re.compile(r"\[SUBJECT\]\s*(.+)")
    chapter_pattern = re.compile(r"\[CHAPTER\]\s*(.+)")
    var_pattern = re.compile(r'set\s+"([^=]+)=(.+?)"')
    m3u8_pattern = re.compile(r'N_m3u8DL-RE\s+"(https?://[^"\s]+)"')
    pdf_pattern = re.compile(r'https?://[^"\s]+\.pdf')

    for raw_line in text.splitlines():
        line = remove_ansi(raw_line)

        m_subj = subject_pattern.search(line)
        if m_subj:
            current_subject = m_subj.group(1).strip()
            current_chapter = None
            continue

        m_chap = chapter_pattern.search(line)
        if m_chap:
            current_chapter = m_chap.group(1).strip()
            continue

        m_var = var_pattern.match(line)
        if m_var:
            var_name = m_var.group(1).strip().lower()
            var_value = m_var.group(2).strip()
            if var_name.startswith("lecture"):
                last_lecture_name = var_value
            elif var_name.startswith("note"):
                last_note_name = var_value
            elif var_name.startswith("dpp_video"):
                last_dpp_video_name = var_value
            elif var_name.startswith("dpp_note"):
                last_dpp_note_name = var_value
            continue

        m_m3u8 = m3u8_pattern.search(raw_line)
        if m_m3u8:
            url = m_m3u8.group(1).strip()
            if last_lecture_name and current_subject and current_chapter:
                data[current_subject][current_chapter]['Lectures'].append(
                    (last_lecture_name, url)
                )
                last_lecture_name = None
            elif last_dpp_video_name and current_subject and current_chapter:
                data[current_subject][current_chapter]['DPP Videos'].append(
                    (last_dpp_video_name, url)
                )
                last_dpp_video_name = None
            continue

        m_pdf = pdf_pattern.search(raw_line)
        if m_pdf:
            url = m_pdf.group(0).strip()
            if last_note_name and current_subject and current_chapter:
                data[current_subject][current_chapter]['Notes'].append(
                    (last_note_name, url)
                )
                last_note_name = None
            elif last_dpp_note_name and current_subject and current_chapter:
                data[current_subject][current_chapter]['DPP Notes'].append(
                    (last_dpp_note_name, url)
                )
                last_dpp_note_name = None
            continue

    return data

def sanitize_name(name: str) -> str:
    return name.replace("/", "-").replace(":", "-").strip()

def generate_output_files(
    data: Dict[str, Dict[str, Dict[str, List[Tuple[str, str]]]]],
    subjects: Iterable[str],
    out_dir: str,
) -> List[str]:
    paths: List[str] = []
    for subject in subjects:
        lines: List[str] = []
        chapters = data[subject]
        for chapter_name, contents in chapters.items():
            ch_prefix = ""
            match = re.match(r"CH\s+\d+", chapter_name, re.IGNORECASE)
            if match:
                ch_prefix = match.group(0) + " "
            for name, url in sorted(contents.get("Lectures", []), key=lambda x: x[0]):
                lines.append(f"{ch_prefix}{name} {url}")
            for name, url in sorted(contents.get("DPP Videos", []), key=lambda x: x[0]):
                lines.append(f"{ch_prefix}{name} {url}")
        safe_subject = sanitize_name(subject)
        file_path = os.path.join(out_dir, f"{safe_subject}.txt")
        with open(file_path, "w", encoding="utf-8") as f:
            f.write("\n".join(lines))
        paths.append(file_path)
    return paths

# ----------- Note parsing and HTML generation (from HTML Note Maker) -----------

def parse_notes(path: Path) -> Dict[str, Dict[str, Dict[str, List[Tuple[str, str]]]]]:
    """Parse notes and DPP notes from the batch file."""
    try:
        text = path.read_text(errors="ignore")
    except FileNotFoundError:
        raise FileNotFoundError(f"The file '{path}' was not found.")

    data = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    current_subject = None
    current_chapter = None
    last_note_name = None
    last_dpp_note_name = None

    subject_pattern = re.compile(r"\[SUBJECT\]\s*(.+)")
    chapter_pattern = re.compile(r"\[CHAPTER\]\s*(.+)")
    var_pattern = re.compile(r'set\s+"([^=]+)=(.+?)"')
    pdf_pattern = re.compile(r'https?://[^"\s]+\.pdf')

    for raw_line in text.splitlines():
        line = remove_ansi(raw_line)
        m_subj = subject_pattern.search(line)
        if m_subj:
            current_subject = m_subj.group(1).strip()
            current_chapter = None
            continue

        m_chap = chapter_pattern.search(line)
        if m_chap:
            current_chapter = m_chap.group(1).strip()
            continue

        m_var = var_pattern.match(line)
        if m_var:
            var_name = m_var.group(1).strip().lower()
            var_value = m_var.group(2).strip()
            if var_name.startswith("note") and not var_name.startswith("note_name"):
                last_note_name = var_value
            elif var_name.startswith("dpp_note"):
                last_dpp_note_name = var_value
            continue

        m_pdf = pdf_pattern.search(raw_line)
        if m_pdf:
            url = m_pdf.group(0).strip()
            if current_subject and current_chapter:
                if last_note_name:
                    data[current_subject][current_chapter]["Notes"].append(
                        (last_note_name, url)
                    )
                    last_note_name = None
                elif last_dpp_note_name:
                    data[current_subject][current_chapter]["DPP Notes"].append(
                        (last_dpp_note_name, url)
                    )
                    last_dpp_note_name = None
            continue

    return data

SUBJECT_METADATA = {
    "Fluid Mechanics": {"icon": "fas fa-water", "desc": "Study of fluids at rest and in motion."},
    "Hydraulic Machine": {"icon": "fas fa-wind", "desc": "Machines that use fluid power to do work."},
    "Strength of Materials": {"icon": "fas fa-weight-hanging", "desc": "Behavior of solid objects subject to stresses and strains."},
    "Heat transfer": {"icon": "fas fa-fire", "desc": "Generation, use, conversion, and exchange of thermal energy."},
    "Material Science": {"icon": "fas fa-flask", "desc": "Design and discovery of new materials."},
    "Theory of Machines and Vibrations": {"icon": "fas fa-cogs", "desc": "Study of the relative motion between the parts of a machine."},
    "Basic Thermodynamics": {"icon": "fas fa-thermometer-half", "desc": "Relations between heat, work, and temperature."},
    "Power Plant": {"icon": "fas fa-bolt", "desc": "Industrial facility for the generation of electric power."},
    "I.C Engine": {"icon": "fas fa-car-battery", "desc": "Heat engine that combusts a substance with an oxidizer."},
    "Refrigeration and Air Conditioning": {"icon": "fas fa-snowflake", "desc": "Technology of chilling spaces and preserving goods."},
    "Renewable Sources of Energy": {"icon": "fas fa-solar-panel", "desc": "Energy collected from renewable resources."},
    "Mechatronics": {"icon": "fas fa-robot", "desc": "Multidisciplinary branch of engineering."},
    "Robotics": {"icon": "fas fa-microchip", "desc": "Design, construction, and use of robots."},
    "Manufacturing Process": {"icon": "fas fa-industry", "desc": "Steps through which raw materials are transformed."},
    "Machine Design": {"icon": "fas fa-drafting-compass", "desc": "Process of designing machines."},
    "Industrial and Maintenance Engineering": {"icon": "fas fa-chart-line", "desc": "Optimization of complex processes or systems."},
    "Engineering Mechanics": {"icon": "fas fa-calculator", "desc": "Application of mechanics to solve engineering problems."}
}

CHAPTER_ICON_KEYWORDS = {
    "Planner": "fas fa-calendar-alt",
    "Practice": "fas fa-pencil-alt",
    "GATE-O-PEDIA": "fas fa-graduation-cap",
    "Quiz": "fas fa-question-circle",
    "Notes": "fas fa-book-open"
}

def generate_notes_html(data: Dict[str, Dict[str, Dict[str, List[Tuple[str, str]]]]],
                        output_path: Path, batch_title: str) -> None:
    """Render a modern, modal-style HTML page of notes by reading from a template file."""
    # Convert notes data to JSON-friendly structure
    notes_json: Dict[str, Dict[str, Dict[str, List[Dict[str, str]]]]] = {}
    for subject, chapters in data.items():
        notes_json[subject] = {}
        for chapter, contents in chapters.items():
            notes_json[subject][chapter] = {}
            for key in ["Notes", "DPP Notes"]:
                items = contents.get(key, [])
                if items:
                    sorted_items = sorted(items, key=lambda x: x[0])
                    notes_json[subject][chapter][key] = [
                        {"name": name, "url": url} for name, url in sorted_items
                    ]

    notes_data_js = json.dumps(notes_json)
    subjects_metadata_js = json.dumps(SUBJECT_METADATA)
    chapter_icons_js = json.dumps(CHAPTER_ICON_KEYWORDS)

    try:
        with open("template.html", "r", encoding="utf-8") as f:
            template_content = f.read()
    except FileNotFoundError:
        logger.error("template.html not found! Cannot generate notes page.")
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write("<html><body><h1>Error: Template file not found.</h1></body></html>")
        return

    # Replace placeholders with actual data
    html_content = template_content.replace("{{BATCH_TITLE}}", html.escape(batch_title))
    html_content = html_content.replace("{{NOTES_DATA_JSON}}", notes_data_js)
    html_content = html_content.replace("{{SUBJECT_METADATA_JSON}}", subjects_metadata_js)
    html_content = html_content.replace("{{CHAPTER_ICONS_JSON}}", chapter_icons_js)

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(html_content)

# ----------- Telegram bot handlers -----------

async def ensure_authorized(update: Update, context: ContextTypes.DEFAULT_TYPE) -> bool:
    user_id = update.effective_user.id
    if user_id not in AUTHORIZED_USERS:
        logger.warning(f"Unauthorized access attempt by user {user_id}")
        if update.message:
            await update.message.reply_text(
                "❌ Sorry, you are not authorised to use this bot."
            )
        elif update.callback_query:
            await update.callback_query.answer(
                "❌ You are not authorised to use this bot.", show_alert=True
            )
        return False
    return True

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not await ensure_authorized(update, context):
        return
    logger.info(f"User {update.effective_user.id} started the bot")
    await update.message.reply_text(
        "👋 Send me a .bat or .txt batch file and I’ll extract the links for you."
    )

async def handle_document(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not await ensure_authorized(update, context):
        return

    document = update.message.document
    filename = document.file_name or "unknown"
    logger.info(
        f"Received document from user {update.effective_user.id}: {filename}"
    )
    if not filename.lower().endswith((".bat", ".txt")):
        await update.message.reply_text("⚠️ Only .bat or .txt files are supported.")
        return

    inspecting_msg = await update.message.reply_text(
        "🔍 Please wait while I inspect the file..."
    )
    context.user_data["inspect_msg_id"] = inspecting_msg.message_id
    context.user_data["batch_name"] = filename

    tmp_dir = "/tmp"
    local_path = os.path.join(tmp_dir, filename)
    file = await document.get_file()
    await file.download_to_drive(local_path)
    logger.info(f"Downloaded file to {local_path}")

    # Save the local path and base name for later use (notes HTML)
    context.user_data["batch_local_path"] = local_path
    context.user_data["batch_base"] = os.path.splitext(filename)[0]

    try:
        data = parse_file(Path(local_path))
    except Exception as exc:
        logger.exception("Error parsing file")
        await update.message.reply_text(f"❌ An error occurred while parsing: {exc}")
        return

    if not data:
        await update.message.reply_text("⚠️ No valid subjects found in the file.")
        return

    try:
        await context.bot.delete_message(
            chat_id=update.effective_chat.id,
            message_id=context.user_data.get("inspect_msg_id"),
        )
    except Exception:
        logger.debug("Failed to delete inspecting message (it may have been deleted)")

    context.user_data["data"] = data
    subjects = list(data.keys())
    context.user_data["subject_list"] = subjects
    context.user_data["selected_subjects"] = set()

    # Log summary of subjects and counts
    summary_strings: List[str] = []
    for subj in subjects:
        count = 0
        for chapter in data[subj].values():
            count += len(chapter.get("Lectures", [])) + len(chapter.get("DPP Videos", []))
        summary_strings.append(f"{subj} ({count} links)")
    logger.info("Inspecting complete. Found subjects: " + ", ".join(summary_strings))

    keyboard = [
        [
            InlineKeyboardButton("📝 Links", callback_data="action_links"),
            InlineKeyboardButton("📄 Notes", callback_data="action_notes"),
        ],
        [InlineKeyboardButton("❌ Close", callback_data="action_close")],
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)

    selection_msg = await update.message.reply_text(
        "✅ File processed successfully. Please choose an action:",
        reply_markup=reply_markup,
    )
    context.user_data["selection_msg_id"] = selection_msg.message_id

async def handle_button(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    query = update.callback_query
    if not await ensure_authorized(update, context):
        await query.answer()
        return

    await query.answer()
    cb_data = query.data

    if cb_data == "action_links":
        subject_list = context.user_data.get("subject_list", [])
        selected: set = context.user_data.get("selected_subjects", set())

        keyboard: List[List[InlineKeyboardButton]] = []
        for i, name in enumerate(subject_list):
            prefix = "✅ " if name in selected else ""
            keyboard.append(
                [InlineKeyboardButton(prefix + name, callback_data=f"toggle_{i}")]
            )

        all_selected = len(selected) == len(subject_list) and subject_list
        toggle_label = "❌ Unselect All" if all_selected else "✅ Select All"
        keyboard.append([InlineKeyboardButton(toggle_label, callback_data="toggle_all")])
        keyboard.append([InlineKeyboardButton("➡️ Proceed", callback_data="proceed")])
        keyboard.append([InlineKeyboardButton("⬅️ Back", callback_data="action_back_to_main")])

        reply_markup = InlineKeyboardMarkup(keyboard)
        await query.edit_message_text(
            text="📚 Select subject(s) to extract links:",
            reply_markup=reply_markup
        )
        return

    elif cb_data == "action_notes":
        await query.edit_message_text("⏳ Generating notes file, please wait...")
        try:
            batch_local_path = context.user_data.get("batch_local_path")
            batch_base_name = context.user_data.get("batch_base", "batch")
            if batch_local_path:
                notes_data = parse_notes(Path(batch_local_path))
                if not notes_data:
                    await query.edit_message_text("⚠️ No notes found in the file.", reply_markup=None)
                    context.user_data.clear()
                    return

                html_file_name = f"{sanitize_name(batch_base_name)}.html"
                html_path = os.path.join("/tmp", html_file_name)
                generate_notes_html(notes_data, Path(html_path), batch_base_name)

                with open(html_path, "rb") as f:
                    await query.message.chat.send_document(
                        document=f,
                        filename=os.path.basename(html_path),
                        caption=f"📝 Notes for {batch_base_name}",
                    )

                await query.message.delete()

                try:
                    os.remove(html_path)
                except Exception as e:
                    logger.debug(f"Failed to delete temporary HTML file {html_path}: {e}")
            else:
                await query.edit_message_text("❌ Could not find the file path. Please send the file again.", reply_markup=None)

        except Exception as e:
            logger.exception(f"Failed to generate and send notes HTML: {e}")
            await query.edit_message_text(f"❌ An error occurred while generating notes: {e}", reply_markup=None)

        context.user_data.clear()
        return

    elif cb_data == "action_close":
        await query.message.delete()
        context.user_data.clear()
        return

    elif cb_data == "action_back_to_main":
        keyboard = [
            [
                InlineKeyboardButton("📝 Links", callback_data="action_links"),
                InlineKeyboardButton("📄 Notes", callback_data="action_notes"),
            ],
            [InlineKeyboardButton("❌ Close", callback_data="action_close")],
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)
        await query.edit_message_text(
            "✅ File processed successfully. Please choose an action:",
            reply_markup=reply_markup,
        )
        return

    # Toggle individual subjects (skip toggle_all)
    if cb_data.startswith("toggle_") and cb_data != "toggle_all":
        index = int(cb_data.split("_")[1])
        subject = context.user_data["subject_list"][index]
        selected: set = context.user_data["selected_subjects"]
        if subject in selected:
            selected.remove(subject)
            logger.info(
                f"User {update.effective_user.id} deselected subject: {subject}"
            )
        else:
            selected.add(subject)
            logger.info(
                f"User {update.effective_user.id} selected subject: {subject}"
            )

        subject_list = context.user_data["subject_list"]
        keyboard: List[List[InlineKeyboardButton]] = []
        for i, name in enumerate(subject_list):
            prefix = "✅ " if name in selected else ""
            keyboard.append(
                [InlineKeyboardButton(prefix + name, callback_data=f"toggle_{i}")]
            )
        all_selected = len(selected) == len(subject_list) and subject_list
        toggle_label = "❌ Unselect All" if all_selected else "✅ Select All"
        keyboard.append([InlineKeyboardButton(toggle_label, callback_data="toggle_all")])
        keyboard.append([InlineKeyboardButton("➡️ Proceed", callback_data="proceed")])
        keyboard.append([InlineKeyboardButton("⬅️ Back", callback_data="action_back_to_main")])
        await query.edit_message_reply_markup(
            reply_markup=InlineKeyboardMarkup(keyboard)
        )
        return

    # Toggle all subjects at once
    if cb_data == "toggle_all":
        subject_list = context.user_data.get("subject_list", [])
        selected: set = context.user_data["selected_subjects"]
        if len(selected) == len(subject_list) and subject_list:
            selected.clear()
            logger.info(f"User {update.effective_user.id} deselected all subjects")
        else:
            selected.clear()
            selected.update(subject_list)
            logger.info(f"User {update.effective_user.id} selected all subjects")
        keyboard: List[List[InlineKeyboardButton]] = []
        for i, name in enumerate(subject_list):
            prefix = "✅ " if name in selected else ""
            keyboard.append(
                [InlineKeyboardButton(prefix + name, callback_data=f"toggle_{i}")]
            )
        all_selected = len(selected) == len(subject_list) and subject_list
        toggle_label = "❌ Unselect All" if all_selected else "✅ Select All"
        keyboard.append([InlineKeyboardButton(toggle_label, callback_data="toggle_all")])
        keyboard.append([InlineKeyboardButton("➡️ Proceed", callback_data="proceed")])
        keyboard.append([InlineKeyboardButton("⬅️ Back", callback_data="action_back_to_main")])
        await query.edit_message_reply_markup(
            reply_markup=InlineKeyboardMarkup(keyboard)
        )
        return

    # Proceed with extraction
    if cb_data == "proceed":
        data = context.user_data.get("data")
        selected: set = context.user_data.get("selected_subjects", set())

        if not selected:
            await query.answer("⚠️ Please select at least one subject to proceed.", show_alert=True)
            return

        subjects: List[str] = list(selected)

        # Summarize and log selected subjects
        summary_extract = []
        for subj in subjects:
            cnt = 0
            for chapter in data[subj].values():
                cnt += len(chapter.get("Lectures", [])) + len(chapter.get("DPP Videos", []))
            summary_extract.append(f"{subj} ({cnt} links)")
        logger.info(
            f"Starting extraction for subjects: {', '.join(summary_extract)}"
        )

        # Remove selection message
        try:
            await query.message.delete()
        except Exception:
            logger.debug("Failed to delete selection message (it may have been deleted)")

        # Inform user that extraction is happening
        extracting_msg = await query.message.chat.send_message(
            "⏳ Extracting links, please wait..."
        )
        context.user_data["extract_msg_id"] = extracting_msg.message_id

        # Generate .txt files and send them
        out_paths = generate_output_files(data, subjects, "/tmp")

        batch_name: str = context.user_data.get("batch_name", "batch")
        batch_base = os.path.splitext(batch_name)[0]

        for subject, path in zip(subjects, out_paths):
            try:
                with open(path, "r", encoding="utf-8") as f:
                    link_count = sum(1 for _ in f)
            except Exception:
                link_count = 0

            logger.info(
                f"Extracted subject: {subject} with {link_count} links"
            )

            if link_count > 0:
                safe_subject = subject.replace('`', "'")
                safe_batch = batch_base.replace('`', "'")
                caption_lines = [
                    f"📂 *Subject:* `{safe_subject}`",
                    f"📦 *Batch Name:* `{safe_batch}`",
                    f"🔗 *Total Links:* {link_count}",
                ]
                caption = "\n".join(caption_lines)

                with open(path, "rb") as f:
                    await query.message.chat.send_document(
                        document=f,
                        filename=os.path.basename(path),
                        caption=caption,
                        parse_mode=ParseMode.MARKDOWN,
                    )
            else:
                await query.message.chat.send_message(
                    f"⚠️ No links found for subject: `{subject}`"
                )

            try:
                os.remove(path)
            except Exception:
                logger.debug(f"Failed to delete temporary file {path}")

            logger.info("Waiting for 7 seconds before next action...")
            await asyncio.sleep(7)

        # Clean up extracting message and notify completion
        try:
            await context.bot.delete_message(
                chat_id=query.message.chat.id,
                message_id=context.user_data.get("extract_msg_id"),
            )
        except Exception:
            logger.debug("Failed to delete extracting message (it may have been deleted)")
        await query.message.chat.send_message("✅ Link extraction complete.")

        context.user_data.clear()
        return

def main() -> None:
    if TOKEN == "YOUR_BOT_TOKEN":
        raise RuntimeError(
            "Please set your Telegram bot token in the TOKEN variable before running."
        )
    if not AUTHORIZED_USERS:
        logger.warning(
            "The authorised user list is empty. Anyone will be able to use the bot."
        )

    app = ApplicationBuilder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.Document.ALL, handle_document))
    app.add_handler(CallbackQueryHandler(handle_button))

    logger.info("Bot is starting...")
    app.run_polling()

if __name__ == "__main__":
    main()
