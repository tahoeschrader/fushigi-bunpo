FROM python:3.12-slim

WORKDIR /app

# Setup baseline layer with pinned versions and no-install-recommends
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential=12.9 \
  libpq-dev=15.13-0+deb12u1 \
  && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install packages without cache
RUN pip install --upgrade pip \
 && pip install --no-cache-dir uv hatchling

# Copy what I need to install
COPY pyproject.toml uv.lock ./
COPY backend/ ./backend/
RUN uv sync --dev

# Set global environment variables (potentially move to env files later)
ENV DATABASE_URL=postgres://postgres:password@db/postgres
