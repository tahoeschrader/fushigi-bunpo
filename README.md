# Fushigi Kaiwa

Assistant for aiding conversational fluency for Japanese language.

Monorepo for backend, database build tools, frontend, and tui.

## Development

Users have two main ways to get involved with this project.

### Option 1: Use Docker

If you have docker installed on your computer, each project can be run as a container via `docker compose up --build`.

### Option 2: Use devenv and direnv

This assumes you have a working NixOS or Nix Home-Manager install with the devenv and direnv packages included.

Then, you simply need to `direnv allow` the root folder and all projects can be spun up with `devenv up` (TODO: broken).

### Setting up a local dev environment

If you aren't using devenv, then you must install the following:

1. `uv` to manage python.
2. `cargo` to manage rust.
3. `bun` to manage typescript.

```shell On sourcing the python virtual environment for IDE
uv venv
source .venv/bin/activate
uv sync --dev
```

For devenv users, the location is included in `.envrc` and auto-sourced for you.
