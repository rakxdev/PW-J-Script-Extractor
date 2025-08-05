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
TOKEN = "7734371947:AAEu32ysTCsJJh0vExhS1dyakId-qT1aOGg"
AUTHORIZED_USERS = {
    7875474866  # Replace with your numeric Telegram user IDs
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
    var_pattern = re.compile(r'set\s+"([^=]+)=([^"\n]+)"')
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
    var_pattern = re.compile(r'set\s+"([^=]+)=([^"\n]+)')
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

def generate_notes_html(data: Dict[str, Dict[str, Dict[str, List[Tuple[str, str]]]]],
                        output_path: Path, batch_title: str) -> None:
    """Render a modal‑style HTML page of notes and DPP notes."""
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

    # CSS styles (copied from the original note maker)
    style_block = """
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(to right, #e0c3fc, #8ec5fc);
            color: #2c3e50;
        }
        .container {
            max-width: 1000px;
            margin: 50px auto;
            background: rgba(255, 255, 255, 0.95);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 12px 30px rgba(0, 0, 0, 0.15);
        }
        h1 {
            font-size: 2.4em;
            text-align: center;
            font-weight: bold;
            color: #111827;
            position: relative;
            margin: 0 auto 20px;
        }
        h1::after {
            content: '';
            position: absolute;
            left: 0;
            right: 0;
            bottom: -6px;
            height: 4px;
            background: linear-gradient(to right, #3b82f6, #a855f7);
            border-radius: 2px;
        }
        .batch-title {
            text-align: center;
            font-size: 1.6em;
            font-weight: bold;
            color: #7b2cbf;
            margin-bottom: 20px;
        }
        .subject-button {
            display: block;
            width: 100%;
            text-align: left;
            padding: 14px 20px;
            margin: 10px 0;
            background-color: #e1bee7;
            border: none;
            border-left: 6px solid #9c27b0;
            border-radius: 8px;
            font-size: 1.1em;
            font-weight: bold;
            color: #3f51b5;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .subject-button:hover {
            background-color: #d1c4e9;
        }
        .telegram-join-button {
            display: inline-block;
            padding: 12px 24px;
            background: linear-gradient(to right, #42a5f5, #7e57c2);
            color: white;
            font-weight: bold;
            border-radius: 10px;
            text-decoration: none;
            margin-top: 30px;
            box-shadow: 0 6px 16px rgba(126, 87, 194, 0.4);
            transition: background 0.3s;
        }
        .telegram-join-button:hover {
            background: linear-gradient(to right, #1e88e5, #5e35b1);
        }
        /* Modal styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.4);
        }
        .modal.show {
            display: block;
        }
        .modal-content {
            background-color: #fff;
            margin: 10% auto;
            padding: 20px 30px;
            border: 1px solid #888;
            width: 80%;
            max-width: 800px;
            border-radius: 10px;
            position: relative;
        }
        .close {
            position: absolute;
            right: 15px;
            top: 10px;
            color: #aaa;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
        }
        .close:hover,
        .close:focus {
            color: #000;
        }
        .chapter-button {
            display: block;
            width: 100%;
            text-align: left;
            padding: 12px 18px;
            margin: 8px 0;
            background-color: #f3e5f5;
            border: none;
            border-radius: 6px;
            font-size: 1.0em;
            font-weight: bold;
            color: #4a148c;
            cursor: pointer;
            transition: background-color 0.3s;
            border-left: 4px solid #ec407a;
            background: #fce4ec;
        }
        .chapter-button:hover {
            background-color: #f8bbd0;
        }
        .back-button {
            display: inline-block;
            margin-bottom: 15px;
            background-color: #e1bee7;
            color: #4a148c;
            padding: 8px 14px;
            border-radius: 6px;
            cursor: pointer;
            border: none;
            transition: background-color 0.3s;
        }
        .back-button:hover {
            background-color: #d1c4e9;
        }
        .note-section-title {
            margin-top: 15px;
            font-size: 1.2em;
            color: #ba68c8;
            font-weight: bold;
            border-bottom: 2px solid #ba68c8;
            padding-bottom: 5px;
        }
        .note-item {
            background: #fce4ec;
            border-left: 4px solid #ec407a;
            padding: 14px 20px;
            margin: 12px 0;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            transition: transform 0.2s;
        }
        .note-item:hover {
            transform: scale(1.02);
        }
        .note-item a {
            color: #d81b60;
            font-weight: 500;
            text-decoration: none;
        }
        .note-item a:hover {
            color: #ad1457;
            text-decoration: underline;
        }
    </style>
    """

    # JavaScript for modal interactions
    script_block = f"""
    <script>
        const notesData = {notes_data_js};
        let currentSubject = null;
        function openSubject(subjectName) {{
            currentSubject = subjectName;
            const modal = document.getElementById('notes-modal');
            const body = document.getElementById('modal-body');
            let html = `<h2>${{subjectName}}</h2>`;
            html += `<span class="close" onclick="closeModal()">&times;</span>`;
            const chapters = Object.keys(notesData[subjectName]);
            chapters.forEach(ch => {{
                const safeCh = ch.replace(/'/g, "\\\\'");
                html += `<button class="chapter-button" onclick="openChapter('${{safeCh}}')">${{ch}}</button>`;
            }});
            body.innerHTML = html;
            modal.classList.add('show');
        }}
        function openChapter(chapterName) {{
            const modal = document.getElementById('notes-modal');
            const body = document.getElementById('modal-body');
            const chapterData = notesData[currentSubject][chapterName];
            let html = `<h2>${{chapterName}}</h2>`;
            html += `<span class="close" onclick="closeModal()">&times;</span>`;
            html += `<button class="back-button" onclick="openSubject('${{currentSubject.replace(/'/g, "\\\\'")}}')">← Back</button>`;
            if (chapterData['Notes'] && chapterData['Notes'].length > 0) {{
                html += `<div class="note-section-title">Notes</div>`;
                chapterData['Notes'].forEach(item => {{
                    html += `<div class="note-item"><a href="${{item.url}}" target="_blank">${{item.name}}</a></div>`;
                }});
            }}
            if (chapterData['DPP Notes'] && chapterData['DPP Notes'].length > 0) {{
                html += `<div class="note-section-title">DPP Notes</div>`;
                chapterData['DPP Notes'].forEach(item => {{
                    html += `<div class="note-item"><a href="${{item.url}}" target="_blank">${{item.name}}</a></div>`;
                }});
            }}
            body.innerHTML = html;
            modal.classList.add('show');
        }}
        function closeModal() {{
            const modal = document.getElementById('notes-modal');
            modal.classList.remove('show');
            currentSubject = null;
        }}
    </script>
    """

    # Build the HTML
    html_parts: List[str] = []
    html_parts.append("<!DOCTYPE html>")
    html_parts.append("<html>\n<head>")
    html_parts.append("    <meta charset=\"utf-8\">\n    <title>๏ ʟᴜᴍɪɴᴏ ⇗ ˣᵖ</title>")
    html_parts.append(style_block)
    html_parts.append(script_block)
    html_parts.append("</head>\n<body>")
    html_parts.append("<div class=\"container\">")
    html_parts.append("    <h1>ɢᴇɴᴇʀᴀᴛᴇᴅ ʙʏ - ๏ ʟᴜᴍɪɴᴏ ⇗ ˣᵖ</h1>")
    html_parts.append(f"    <h2 class=\"batch-title\">{html.escape(batch_title)} - Notes</h2>")
    html_parts.append("    <a class=\"telegram-join-button\" href=\"https://t.me/luminoxpp\" target=\"_blank\">Join Telegram Channel</a>")
    # Render subject buttons
    for subject in data:
        if subject == "Telegram Bot":
            chapter_dict = next(iter(data[subject].values())) if data[subject] else {}
            notes_list = chapter_dict.get("Notes", [])
            bot_url = notes_list[0][1] if notes_list else "https://t.me/luminoxpp"
            html_parts.append(
                f"    <button class=\"subject-button\" onclick=\"window.open('{html.escape(bot_url)}', '_blank')\">{html.escape(subject)}</button>"
            )
        else:
            safe_subject = subject.replace("'", "\\'")
            html_parts.append(
                f"    <button class=\"subject-button\" onclick=\"openSubject('{safe_subject}')\">{html.escape(subject)}</button>"
            )
    html_parts.append("</div>")  # container end
    # Modal container
    html_parts.append(
        "<div id=\"notes-modal\" class=\"modal\">\n"
        "  <div class=\"modal-content\">\n"
        "    <div id=\"modal-body\"></div>\n"
        "  </div>\n"
        "</div>"
    )
    html_parts.append("</body>\n</html>")

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("\n".join(html_parts))

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

    keyboard: List[List[InlineKeyboardButton]] = []
    for i, subject in enumerate(subjects):
        keyboard.append(
            [InlineKeyboardButton(subject, callback_data=f"toggle_{i}")]
        )
    # Initially, no subjects are selected -> show "Select All"
    keyboard.append([InlineKeyboardButton("✅ Select All", callback_data="toggle_all")])
    keyboard.append([InlineKeyboardButton("➡️ Proceed", callback_data="proceed")])
    reply_markup = InlineKeyboardMarkup(keyboard)

    selection_msg = await update.message.reply_text(
        "📚 Select subject(s) to extract:",
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
        await query.edit_message_reply_markup(
            reply_markup=InlineKeyboardMarkup(keyboard)
        )
        return

    # Proceed with extraction
    if cb_data == "proceed":
        data = context.user_data.get("data")
        selected: set = context.user_data.get("selected_subjects")
        subject_list_full = context.user_data.get("subject_list", [])
        # Determine if all subjects are selected (either explicitly or by default)
        all_selected_flag = False
        if not selected:
            all_selected_flag = True
        else:
            all_selected_flag = len(selected) == len(subject_list_full)
        subjects: List[str] = (
            list(selected) if selected else subject_list_full
        )

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
            "⏳ Extracting, please wait..."
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
            safe_subject = subject.replace('`', "'")
            safe_batch = batch_base.replace('`', "'")
            caption_lines = [
                f"📂 *Subject:* `{safe_subject}`",
                f"📦 *Batch Name:* `{safe_batch}`",
                f"🔗 *Total Links:* {link_count}",
            ]
            caption = "\n".join(caption_lines)
            logger.info(
                f"Extracted subject: {subject} with {link_count} links"
            )
            with open(path, "rb") as f:
                await query.message.chat.send_document(
                    document=f,
                    filename=os.path.basename(path),
                    caption=caption,
                    parse_mode=ParseMode.MARKDOWN,
                )
            try:
                os.remove(path)
            except Exception:
                logger.debug(f"Failed to delete temporary file {path}")

        # If all subjects were selected, also generate and send the notes HTML
        if all_selected_flag:
            try:
                batch_local_path = context.user_data.get("batch_local_path")
                batch_base_name = context.user_data.get("batch_base", "batch")
                if batch_local_path:
                    notes_data = parse_notes(Path(batch_local_path))
                    html_file_name = f"{sanitize_name(batch_base_name)}.html"
                    html_path = os.path.join("/tmp", html_file_name)
                    generate_notes_html(notes_data, Path(html_path), batch_base_name)
                    with open(html_path, "rb") as f:
                        await query.message.chat.send_document(
                            document=f,
                            filename=os.path.basename(html_path),
                            caption=f"📝 Notes for {batch_base_name}",
                        )
                    try:
                        os.remove(html_path)
                    except Exception:
                        logger.debug(f"Failed to delete temporary HTML file {html_path}")
            except Exception as e:
                logger.exception(f"Failed to generate and send notes HTML: {e}")

        # Clean up extracting message and notify completion
        try:
            await context.bot.delete_message(
                chat_id=query.message.chat.id,
                message_id=context.user_data.get("extract_msg_id"),
            )
        except Exception:
            logger.debug("Failed to delete extracting message (it may have been deleted)")
        await query.message.chat.send_message("✅ Extraction complete.")

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
