# Fushigi Kaiwa

Assistant for aiding conversational fluency for Japanese language.

Monorepo for backend, database build tools, frontend, and tui. 

## Development

Install `uv` to manage python virtual environments and requirements. Docker is also using the `uv` platform.

This simplifies the dev process to the following:

```shell Set up local dev environment
cd this/repo
uv venv
source .venv/bin/activate
uv sync --dev
```

```shell Build, test, and run
cd this/repo
docker compose up --build
```

```shell Locally test and run
cd sub/repo/project
uv run pytest
uv run python -m main
```

```shell Turn on db, api, and app
docker compose up --build
cd app
bun run dev --open
```

Whenever new dependencies are added to subfolder `pyproject.toml`, remember to `uv lock` from the root to update the lockfile. 
