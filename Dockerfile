##
## Dockerfile for Telegram Link Extractor Bot
##
## This Dockerfile builds a lightweight image capable of running
## the Telegram link extraction bot.  It installs Python, copies
## the application files and installs the required dependencies.

FROM python:3.12-slim AS base

# Create application directory
WORKDIR /app

# Copy the dependency specification and install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# Copy the bot source code into the image
COPY bot.py /app/

# Set the default command to run the bot.  Override the environment
# variable BOT_TOKEN at runtime if you don't want to hard‑code it.
CMD ["python", "-u", "bot.py"]
