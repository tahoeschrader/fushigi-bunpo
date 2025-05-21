FROM python:3.12-slim

WORKDIR /app
COPY pyproject.toml .

RUN apt-get update && apt-get install -y \
  build-essential \
  libpq-dev \
  && rm -rf /var/lib/apt/lists/*
RUN pip install --upgrade pip setuptools wheel
RUN pip install ".[dev]"

COPY . .

ENV DATABASE_URL=postgres://postgres:password@db/postgres

CMD ["python", "-m", "main"]
