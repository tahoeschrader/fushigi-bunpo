# db-tools

This is a python package used to build a PostgreSQL database and fill it with grammar I sourced myself
over the past year while studying in Japan. Various nuances have been enhanced via ChatGPT but basic patterns and
sentences all came from either my head or the textbook we used in class.

## Development

Install `uv` to manage python virtual environments. Then, source and lock dependencies via:

```shell
cd this/project/sub/repo
uv venv
source .venv/bin/acivate
uv pip install -r pyproject.toml --extra dev
```

When new dependencies are added to the project, remove your virtual environment and run:

```shell
uv pip install -r pyproject.toml
uv pip freeze > requirements.txt
```

This makes sure the dev dependencies are not included. 
