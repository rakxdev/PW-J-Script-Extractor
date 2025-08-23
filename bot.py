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
# TOKEN = "7760431264:AAEhbngfFwxMp2nmD6jzzYvPoBUPBMGW8e0"
# AUTHORIZED_USERS = {
#     7875474866,
#     1955134660,
#     1429154571,
#     7073085399  # Replace with your numeric Telegram user IDs
# }

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

def generate_notes_html(data: Dict[str, Dict[str, Dict[str, List[Tuple[str, str]]]]],
                        output_path: Path, batch_title: str) -> None:
    """Render a modern, modal-style HTML page of notes and DPP notes."""
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

    html_content = f"""
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>๏ ʟᴜᴍɪɴᴏ ⇗ ˣᵖ | Elegant Notes Portal</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {{
            --primary: #0ff;
            --secondary: #f0f;
            --accent: #ff0;
            --dark: #0a0a1a;
            --darker: #050510;
            --light: #e0e0ff;
            --card-bg: rgba(15, 15, 35, 0.7);
            --border-primary: rgba(0, 255, 255, 0.3);
            --border-secondary: rgba(255, 0, 255, 0.3);
            --text-primary: #e0f7ff;
            --text-secondary: #c0d0e0;
        }}

        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }}

        body {{
            background: linear-gradient(135deg, var(--darker), #1a1a2e);
            color: var(--text-primary);
            min-height: 100vh;
            padding: 20px;
            background-attachment: fixed;
            overflow-x: hidden;
        }}

        .container {{
            max-width: 1200px;
            margin: 0 auto;
        }}

        header {{
            text-align: center;
            padding: 30px 0;
            position: relative;
            margin-bottom: 30px;
        }}

        .logo {{
            font-size: 2.8rem;
            margin-bottom: 10px;
            color: var(--primary);
            filter: drop-shadow(0 0 8px rgba(0, 255, 255, 0.4));
        }}

        h1 {{
            font-size: 2.4rem;
            margin-bottom: 10px;
            background: linear-gradient(to right, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
        }}

        .batch-title {{
            font-size: 1.2rem;
            color: var(--accent);
            margin-bottom: 25px;
            font-weight: 500;
        }}

        .telegram-join-button {{
            display: inline-flex;
            align-items: center;
            padding: 14px 30px;
            background: linear-gradient(45deg, var(--primary), var(--secondary));
            color: var(--darker);
            font-weight: bold;
            font-size: 1.1rem;
            border-radius: 50px;
            text-decoration: none;
            margin: 20px 0 40px;
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }}

        .telegram-join-button:hover {{
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 255, 255, 0.3);
        }}

        .telegram-join-button i {{
            margin-right: 10px;
        }}

        .subjects-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 20px;
            margin-top: 30px;
        }}

        .subject-card {{
            background: var(--card-bg);
            border-radius: 12px;
            padding: 25px 20px;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 1px solid var(--border-secondary);
            position: relative;
            overflow: hidden;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
        }}

        .subject-card::before {{
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(to right, var(--primary), var(--secondary));
        }}

        .subject-card:hover {{
            transform: translateY(-5px);
            border-color: var(--primary);
        }}

        .subject-icon {{
            font-size: 2.2rem;
            margin-bottom: 15px;
            color: var(--primary);
        }}

        .subject-name {{
            font-size: 1.3rem;
            font-weight: 600;
            margin-bottom: 10px;
            color: var(--light);
        }}

        .subject-desc {{
            font-size: 0.95rem;
            color: var(--text-secondary);
            margin-bottom: 15px;
            line-height: 1.5;
        }}

        .chapter-count {{
            display: inline-block;
            background: rgba(0, 255, 255, 0.1);
            color: var(--primary);
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 500;
        }}

        /* Modal Styles */
        .modal {{
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(5, 5, 15, 0.95);
            z-index: 1000;
            overflow-y: auto;
            padding: 20px;
        }}

        .modal.show {{
            display: block;
            animation: fadeIn 0.3s ease;
        }}

        @keyframes fadeIn {{
            from {{
                opacity: 0;
            }}

            to {{
                opacity: 1;
            }}
        }}

        .modal-content {{
            background: var(--card-bg);
            max-width: 900px;
            margin: 50px auto;
            border-radius: 15px;
            padding: 30px;
            border: 1px solid var(--border-primary);
            position: relative;
        }}

        .modal-header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border-secondary);
        }}

        .modal-title {{
            font-size: 1.8rem;
            color: var(--primary);
        }}

        .close-modal {{
            background: none;
            border: none;
            color: var(--text-secondary);
            font-size: 1.8rem;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
        }}

        .close-modal:hover {{
            color: var(--accent);
            background: rgba(255, 255, 255, 0.1);
        }}

        .back-button {{
            display: inline-flex;
            align-items: center;
            background: rgba(255, 0, 255, 0.1);
            color: var(--secondary);
            border: 1px solid var(--border-secondary);
            padding: 10px 20px;
            border-radius: 30px;
            cursor: pointer;
            margin-bottom: 25px;
            transition: all 0.3s ease;
            font-weight: 500;
            font-size: 0.95rem;
        }}

        .back-button:hover {{
            background: rgba(255, 0, 255, 0.2);
        }}

        .back-button i {{
            margin-right: 8px;
        }}

        .chapters-container {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 18px;
            margin-bottom: 30px;
        }}

        .chapter-card {{
            background: rgba(15, 15, 35, 0.5);
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 1px solid rgba(0, 255, 255, 0.1);
        }}

        .chapter-card:hover {{
            transform: translateY(-3px);
            border-color: var(--primary);
        }}

        .chapter-icon {{
            font-size: 2rem;
            margin-bottom: 15px;
            color: var(--secondary);
        }}

        .chapter-name {{
            font-size: 1.1rem;
            font-weight: 500;
            color: var(--light);
        }}

        .notes-section {{
            margin-top: 30px;
        }}

        .section-title {{
            font-size: 1.4rem;
            color: var(--accent);
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--accent);
        }}

        .notes-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
            gap: 18px;
        }}

        .note-card {{
            background: rgba(15, 15, 35, 0.5);
            border-radius: 12px;
            padding: 20px;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 0, 0.1);
            position: relative;
            overflow: hidden;
        }}

        .note-card:hover {{
            transform: translateY(-3px);
            border-color: var(--accent);
        }}

        .note-card::before {{
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 3px;
            background: linear-gradient(to right, var(--accent), var(--secondary));
        }}

        .note-title {{
            font-size: 1rem;
            font-weight: 500;
            margin-bottom: 15px;
            color: var(--light);
            line-height: 1.4;
        }}

        .note-link {{
            display: inline-flex;
            align-items: center;
            background: rgba(255, 255, 0, 0.1);
            color: var(--accent);
            padding: 10px 20px;
            border-radius: 30px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
            border: 1px solid rgba(255, 255, 0, 0.2);
            font-size: 0.9rem;
        }}

        .note-link:hover {{
            background: rgba(255, 255, 0, 0.2);
        }}

        .note-link i {{
            margin-left: 8px;
        }}

        footer {{
            text-align: center;
            padding: 30px 0;
            margin-top: 40px;
            color: #777;
            font-size: 0.9rem;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
        }}

        .footer-logo {{
            font-size: 1.3rem;
            margin-bottom: 10px;
            color: var(--primary);
        }}

        /* Responsive Design */
        @media (max-width: 992px) {{
            .subjects-grid {{
                grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            }}

            .modal-content {{
                margin: 30px auto;
                padding: 25px;
            }}

            .modal-title {{
                font-size: 1.6rem;
            }}

            h1 {{
                font-size: 2rem;
            }}

            .logo {{
                font-size: 2.3rem;
            }}
        }}

        @media (max-width: 768px) {{
            .subjects-grid {{
                grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            }}

            .chapters-container,
            .notes-grid {{
                grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            }}

            .stat-card {{
                min-width: 130px;
                padding: 15px;
            }}

            .stat-card .number {{
                font-size: 1.4rem;
            }}

            .stat-card .label {{
                font-size: 0.8rem;
            }}
        }}

        @media (max-width: 576px) {{
            .subjects-grid {{
                grid-template-columns: 1fr;
            }}

            .chapters-container,
            .notes-grid {{
                grid-template-columns: 1fr;
            }}

            .modal-content {{
                margin: 20px auto;
                padding: 20px;
            }}

            .modal-header {{
                flex-direction: column;
                align-items: flex-start;
            }}

            .close-modal {{
                position: absolute;
                top: 15px;
                right: 15px;
            }}

            h1 {{
                font-size: 1.8rem;
            }}

            .logo {{
                font-size: 2rem;
            }}

            .batch-title {{
                font-size: 1rem;
            }}
        }}

        @media (max-width: 400px) {{
            .container {{
                padding: 10px;
            }}

            .subject-card {{
                padding: 20px 15px;
            }}

            .subject-name {{
                font-size: 1.1rem;
            }}

            .subject-desc {{
                font-size: 0.85rem;
            }}
        }}


        .batch-title {{
            font-size: 1rem;
            word-break: break-word;
            /* ✅ breaks long names */
            text-align: center;
            line-height: 1.4;
            padding: 0 10px;
        }}

        /* Subject cards */
        .subject-card {{
            padding: 18px 12px;
            /* ✅ less padding on mobile */
        }}

        .subject-name {{
            font-size: 1.1rem;
        }}

        .subject-desc {{
            font-size: 0.85rem;
            line-height: 1.3;
        }}

        /* Modal adjustments for mobile */
        @media (max-width: 576px) {{
            .modal-content {{
                margin: 10px auto;
                padding: 15px;
                width: 95%;
            }}

            .modal-title {{
                font-size: 1.3rem;
                line-height: 1.4;
                word-break: break-word;
                /* ✅ long subject names wrap */
            }}

            .notes-grid,
            .chapters-container {{
                grid-template-columns: 1fr;
            }}
        }}

        /* Stat cards stack better */
        @media (max-width: 400px) {{
            .stat-card {{
                width: 100%;
                max-width: 220px;
            }}
        }}


        .subject-name {{
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }}
    </style>
</head>

<body>
    <div class="container">
        <header>
            <div class="logo">
                <i class="fas fa-atom"></i>
            </div>
            <h1>๏ ʟᴜᴍɪɴᴏ ⇗ ˣᵖ</h1>
            <div class="batch-title">{html.escape(batch_title)}</div>

            <a class="telegram-join-button" href="https://t.me/luminoxpp" target="_blank">
                <i class="fab fa-telegram-plane"></i> Join Telegram Channel
            </a>
        </header>

        <main>
            <div class="subjects-grid">
                <!-- Subject cards will be generated by JavaScript -->
            </div>
        </main>

        <footer>
            <div class="footer-logo">๏ ʟᴜᴍɪɴᴏ ⇗ ˣᵖ</div>
            <p>Generated by LuminO XP | Elegant Notes Portal</p>
            <p>All rights reserved © 2023</p>
        </footer>
    </div>

    <!-- Modal for subject details -->
    <div id="subject-modal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <h2 class="modal-title" id="modal-title">Subject Title</h2>
                <button class="close-modal" id="close-modal">&times;</button>
            </div>
            <div id="modal-body">
                <!-- Content will be populated by JavaScript -->
            </div>
        </div>
    </div>

    <script>
        const notesData = {notes_data_js};
        const subjectMetadata = {subjects_metadata_js};

        // DOM Elements
        const subjectsGrid = document.querySelector('.subjects-grid');
        const modal = document.getElementById('subject-modal');
        const modalTitle = document.getElementById('modal-title');
        const modalBody = document.getElementById('modal-body');
        const closeModalBtn = document.getElementById('close-modal');

        // Generate subject cards dynamically
        Object.keys(notesData).forEach(subjectName => {{
            const card = document.createElement('div');
            card.className = 'subject-card';

            const metadata = subjectMetadata[subjectName] || {{ icon: 'fas fa-book', desc: 'Notes and videos for this subject.' }};
            const chapterCount = Object.keys(notesData[subjectName]).length;

            card.innerHTML = `
                <div class="subject-icon">
                    <i class="${{metadata.icon}}"></i>
                </div>
                <h3 class="subject-name">${{subjectName}}</h3>
                <p class="subject-desc">${{metadata.desc}}</p>
                <div class="chapter-count">${{chapterCount}} ${{chapterCount === 1 ? 'Chapter' : 'Chapters'}}</div>
            `;
            card.addEventListener('click', () => openSubject(subjectName));
            subjectsGrid.appendChild(card);
        }});

        // Open subject modal
        function openSubject(subjectName) {{
            modalTitle.textContent = subjectName;
            modalBody.innerHTML = '';

            const chapters = notesData[subjectName];
            if (Object.keys(chapters).length > 0) {{
                const chaptersSection = document.createElement('div');
                chaptersSection.className = 'chapters-container';

                Object.keys(chapters).forEach(chapterName => {{
                    const chapterCard = document.createElement('div');
                    chapterCard.className = 'chapter-card';
                    chapterCard.innerHTML = `
                        <div class="chapter-icon">
                            <i class="fas fa-folder-open"></i>
                        </div>
                        <div class="chapter-name">${{chapterName}}</div>
                    `;
                    chapterCard.addEventListener('click', () => openChapter(subjectName, chapterName));
                    chaptersSection.appendChild(chapterCard);
                }});
                modalBody.appendChild(chaptersSection);
            }} else {{
                modalBody.innerHTML += '<p>No chapters found for this subject.</p>';
            }}
             modal.classList.add('show');
        }}

        // Open chapter details
        function openChapter(subjectName, chapterName) {{
            modalBody.innerHTML = '';

            const backButton = document.createElement('button');
            backButton.className = 'back-button';
            backButton.innerHTML = `<i class="fas fa-arrow-left"></i> Back to ${{subjectName}} Chapters`;
            backButton.addEventListener('click', () => openSubject(subjectName));
            modalBody.appendChild(backButton);

            const chapterTitle = document.createElement('h3');
            chapterTitle.className = 'section-title';
            chapterTitle.textContent = chapterName;
            modalBody.appendChild(chapterTitle);

            const chapterData = notesData[subjectName][chapterName];
            const notesGrid = document.createElement('div');
            notesGrid.className = 'notes-grid';

            let notesFound = false;
            if (chapterData['Notes'] && chapterData['Notes'].length > 0) {{
                notesFound = true;
                chapterData['Notes'].forEach(note => {{
                    const noteCard = document.createElement('div');
                    noteCard.className = 'note-card';
                    noteCard.innerHTML = `
                        <div class="note-title">${{note.name}}</div>
                        <a href="${{note.url}}" target="_blank" class="note-link">
                            Download PDF <i class="fas fa-download"></i>
                        </a>
                    `;
                    notesGrid.appendChild(noteCard);
                }});
            }}
            if (chapterData['DPP Notes'] && chapterData['DPP Notes'].length > 0) {{
                notesFound = true;
                chapterData['DPP Notes'].forEach(note => {{
                    const noteCard = document.createElement('div');
                    noteCard.className = 'note-card';
                    noteCard.innerHTML = `
                        <div class="note-title">${{note.name}}</div>
                        <a href="${{note.url}}" target="_blank" class="note-link">
                            Download PDF <i class="fas fa-download"></i>
                        </a>
                    `;
                    notesGrid.appendChild(noteCard);
                }});
            }}

            if (notesFound) {{
                modalBody.appendChild(notesGrid);
            }} else {{
                modalBody.innerHTML += '<p>No notes found for this chapter.</p>';
            }}
        }}

        // Close modal
        function closeModal() {{
            modal.classList.remove('show');
        }}

        // Event listeners
        closeModalBtn.addEventListener('click', closeModal);
        window.addEventListener('click', (e) => {{
            if (e.target === modal) {{
                closeModal();
            }}
        }});
    </script>
</body>
</html>
    """
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
