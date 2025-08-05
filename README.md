# PW-J-Script-Extractor Bot

This repository contains a Telegram bot that parses specially formatted
batch (`.bat`) or text (`.txt`) files and extracts links to lectures,
notes and DPP videos.  The bot lets you choose which subjects to
extract, produces plain‑text files with the links, and optionally
generates a rich HTML document listing notes when you extract all
subjects at once.  Files are sent back to the user through
Telegram.  The bot also uses a whitelist of authorised user IDs to
prevent unauthorised access.

## Features

* Parses batch or text files to discover subjects, chapters, lecture
  URLs and notes.
* Interactive inline keyboard with checkmarks and a **Select/Unselect
  All** toggle.
* Generates `.txt` files for each selected subject containing
  lecture/DPP video links.  Filenames correspond to the subject.
* Generates a single HTML file when all subjects are selected,
  containing a modal‑style interface for class notes and DPP notes.
* Cleans up temporary files after sending documents to the user.
* Configurable whitelist (`AUTHORIZED_USERS`) to restrict bot usage.
* Uses clean logging with extraneous HTTP noise suppressed.

## Prerequisites

* A Telegram bot token obtained via [@BotFather](https://core.telegram.org/bots#botfather).
* Python 3.9 or newer (for local installation) or Docker (for
  containerised deployment).

## Local Installation

1. **Clone the repository** (if you haven’t already):

   ```bash
   git clone https://github.com/rakxdev/PW-J-Script-Extractor pwj-ext
   cd pwj-ext
   ```

2. **Create and activate a virtual environment** (recommended):

   ```bash
   python3 -m venv venv
   source venv/bin/activate
   ```

3. **Install dependencies** using `requirements.txt`:

   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

4. **Configure the bot**:

   * Open `telegram_bot.py` in a text editor.
   * Replace `TOKEN` with your Telegram bot token.
   * Replace or update the `AUTHORIZED_USERS` set with the numeric
     Telegram user IDs that should be allowed to use the bot.

5. **Run the bot**:

   ```bash
   python bot.py
   ```

6. The bot will start polling for updates.  You can now send a `.bat`
   or `.txt` file to your bot in Telegram and follow the prompts.

## Running with Docker

The provided `Dockerfile` can build a container image containing
everything needed to run the bot.  This is useful if you prefer not
to install Python and dependencies directly on your system.

1. **Build the Docker image** (from the root of this repository):

   ```bash
   docker build -t telegram-link-extractor .
   ```

   This command creates a Docker image called
   `telegram-link-extractor` containing Python, the bot code and its
   dependencies.

2. **Run the container**:

   ```bash
   docker run -d --name link-extractor-bot telegram-link-extractor
   ```

   * Replace `<your-telegram-bot-token>` with the token obtained from
     @BotFather.
   * Replace `user_id1,user_id2` with the comma‑separated list of
     numeric Telegram user IDs allowed to use the bot.  If you omit
     `AUTHORIZED_USERS`, the bot will allow any user.
   * The container runs in detached mode (`-d`) and listens for
     updates.  You can check logs with:

     ```bash
     docker logs -f link-extractor-bot
     ```

3. **Stop the container** when you’re finished:

   ```bash
   docker stop link-extractor-bot
   ```

4. **Remove the container** (if you no longer need it):

   ```bash
   docker rm link-extractor-bot
   ```

5. **Remove the image** (optional, if you want to free disk space):

   ```bash
   docker rmi telegram-link-extractor
   ```

## Environment Variables

The Docker container supports the following environment variables:

| Variable           | Description                                                                                                              |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| `BOT_TOKEN`        | Your Telegram bot token.  Required to connect to Telegram.                                                               |
| `AUTHORIZED_USERS` | Comma‑separated list of numeric Telegram user IDs allowed to use the bot.  If omitted or empty, all users are permitted. |

## Security Considerations

* Keep your bot token secret.  Do not hard‑code it in public
  repositories.  When deploying with Docker, use environment
  variables or secrets.
* Configure `AUTHORIZED_USERS` to prevent unauthorised access to
  extracted links and notes.

## Cleaning Up Docker Resources

To remove all traces of this bot from your system after testing:

1. **Stop and remove the running container** (if still running):

   ```bash
   docker stop link-extractor-bot || true
   docker rm link-extractor-bot || true
   ```

2. **Remove the image**:

   ```bash
   docker rmi telegram-link-extractor
   ```

3. **Prune unused resources** (optional):

   ```bash
   docker system prune --volumes
   ```

   The last command removes unused containers, networks, images and
   dangling build cache layers.  Use with caution on shared hosts.

## Contributing

Pull requests are welcome!  If you find a bug or have an enhancement
idea, please open an issue or submit a patch.

## License

This project is provided without warranty under the terms of the MIT
License.  See `LICENSE` for details if included, or assume MIT.
