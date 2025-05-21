FROM python:3.12-slim

WORKDIR /app

# Setup baseline layer
RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip setuptools wheel

# Copy what I need to install
COPY pyproject.toml .
RUN pip install ".[dev]"

# Copy the rest (ignore what's in .dockerignore)
COPY . .

ENV DATABASE_URL=postgres://postgres:password@db/postgres

CMD ["python", "-m", "main"]
