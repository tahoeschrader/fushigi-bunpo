FROM python:3.12-slim

WORKDIR /app

# Setup baseline layer
RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip \
 && pip install --no-cache-dir uv hatchling

# Copy what I need to install
COPY pyproject.toml uv.lock ./
COPY backend/ ./backend/
RUN uv sync --dev

# Set global environment variables (potentially what this in env files maybe?)
ENV DATABASE_URL=postgres://postgres:password@db/postgres
