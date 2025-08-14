# -*- coding: utf-8 -*-
"""
Unit tests for Nix development environment configuration.

Testing library/framework: pytest
- These tests validate that the dev environment Nix module contains critical configuration
  entries introduced or modified in the PR diff (git hooks, services, languages, and processes).
- Tests are text-based and robust to minor whitespace differences, using regular expressions.

To point tests at a different Nix file path, set environment variable:
    DEVENV_NIX_FILE=/path/to/devenv.nix
"""

import os
import re
import pytest

# Default to auto-discovered path injected during generation; can be overridden by env var.
NIX_FILE_PATH = os.environ.get("DEVENV_NIX_FILE", r"""devenv.nix""")

@pytest.fixture(scope="module")
def nix_text():
    """
    Loads the Nix file content. If not found, skip the suite so CI does not fail
    in environments where the devenv file is not present.
    """
    if not os.path.exists(NIX_FILE_PATH):
        pytest.skip(f"Nix config file not found at {NIX_FILE_PATH}. Set DEVENV_NIX_FILE to override.")
    with open(NIX_FILE_PATH, "r", encoding="utf-8") as f:
        return f.read()

# -----------------------------
# Git hooks and linters
# -----------------------------

def test_git_hooks_default_stages(nix_text):
    # Expect: git-hooks.default_stages = ["pre-push" "manual"];
    assert re.search(r'git-hooks\.default_stages\s*=\s*\[\s*"pre-push"\s*"manual"\s*\]\s*;', nix_text)

def test_gitleaks_hook_enabled_and_entry(nix_text):
    assert re.search(r'git-hooks\.hooks\.\s*commitizen\.enable\s*=\s*true\s*;', nix_text)
    assert re.search(r'gitleaks\s*=\s*\{[^}]*enable\s*=\s*true[^}]*entry\s*=\s*"\$\{pkgs\.gitleaks\}/bin/gitleaks protect --redact"\s*;', nix_text, re.S)

def test_lychee_settings_excludes_specific_urls(nix_text):
    assert "lychee.settings.configPath" in nix_text
    for url in ["localhost", "file://", "https://shadcn-svelte.com/registry", "http://192.168.11.5:8000"]:
        assert url in nix_text

def test_markdownlint_md013_line_length_disabled(nix_text):
    assert re.search(r'markdownlint\.settings\.configuration\.MD013\.line_length\s*=\s*-1\s*;', nix_text)

def test_typos_excludes_and_ignored_words(nix_text):
    assert re.search(r'typos\.excludes\s*=\s*\[\s*"\.\*grammar\.json"\s*\]\s*;', nix_text)
    assert re.search(r'typos\.settings\.ignored-words\s*=\s*\[\s*"ratatui"\s*\]\s*;', nix_text)

def test_precommit_builtin_hooks_enabled(nix_text):
    for key in [
        r'check-added-large-files',
        r'check-case-conflicts',
        r'check-executables-have-shebangs',
        r'check-merge-conflicts',
        r'check-symlinks',
        r'check-vcs-permalinks',
        r'end-of-file-fixer',
        r'fix-byte-order-marker',
        r'forbid-new-submodules',
        r'mixed-line-endings',
        r'no-commit-to-branch',
        r'trim-trailing-whitespace',
    ]:
        assert re.search(rf'{re.escape(key)}\.enable\s*=\s*true\s*;', nix_text)
    assert re.search(r'no-commit-to-branch\.settings\.branch\s*=\s*\[\s*"main"\s*\]\s*;', nix_text)

# -----------------------------
# Language support
# -----------------------------

def test_languages_nix_enabled(nix_text):
    assert re.search(r'languages\.nix\.enable\s*=\s*true\s*;', nix_text)

def test_python_backend_setup(nix_text):
    assert re.search(r'languages\.python\s*=\s*\{[^}]*enable\s*=\s*true', nix_text, re.S)
    assert re.search(r'languages\.python\s*=\s*\{[^}]*directory\s*=\s*"\./backend"', nix_text, re.S)
    assert re.search(r'uv\.enable\s*=\s*true\s*;', nix_text)
    assert re.search(r'uv\.sync\.enable\s*=\s*true\s*;', nix_text)

def test_rust_language_and_hooks(nix_text):
    assert re.search(r'languages\.rust\.enable\s*=\s*true\s*;', nix_text)
    assert re.search(r'clippy\.enable\s*=\s*true\s*;', nix_text)
    assert re.search(r'rustfmt\.enable\s*=\s*true\s*;', nix_text)

def test_frontend_biome_and_bun_setup(nix_text):
    assert re.search(r'git-hooks\.hooks\.biome\.enable\s*=\s*true\s*;', nix_text)
    assert "VITE_API_BASE" in nix_text
    assert re.search(r'bun --bun run dev --open', nix_text)
    assert re.search(r'languages\s*=\s*\{[^}]*typescript\.enable\s*=\s*true', nix_text, re.S)
    assert re.search(r'javascript\s*=\s*\{[^}]*enable\s*=\s*true[^}]*directory\s*=\s*"\./frontend"[^}]*bun\.enable\s*=\s*true[^}]*bun\.install\.enable\s*=\s*true', nix_text, re.S)

# -----------------------------
# Services and processes
# -----------------------------

def test_postgres_service_and_init_db(nix_text):
    assert re.search(r'services\.postgres\s*=\s*\{[^}]*enable\s*=\s*true', nix_text, re.S)
    assert re.search(r'listen_addresses\s*=\s*"localhost"\s*;', nix_text)
    assert re.search(r'initialDatabases\s*=\s*lib\.toList\s*\{[^}]*name\s*=\s*"postgres"[^}]*user\s*=\s*"postgres"[^}]*pass\s*=\s*"postgres"[^}]*schema\s*=\s*\./backend/sql\s*;', nix_text, re.S)

def test_adminer_and_dependencies(nix_text):
    assert re.search(r'services\.adminer\.enable\s*=\s*true\s*;', nix_text)
    assert re.search(r'processes\.adminer\.process-compose\.depends_on\.postgres\.condition\s*=\s*"process_healthy"\s*;', nix_text)

def test_generate_default_db_process(nix_text):
    assert re.search(r'processes\.generate-default-db\.exec\s*=\s*"uv run python -m fushigi_backend\.tools_main"\s*;', nix_text)
    assert re.search(r'processes\.generate-default-db\.process-compose\s*=\s*\{[^}]*environment\s*=\s*\[\s*"DATABASE_URL=postgres://postgres:postgres@localhost:5432/postgres"\s*\]', nix_text, re.S)
    assert re.search(r'processes\.generate-default-db\.process-compose\s*=\s*\{[^}]*working_dir\s*=\s*"\./backend"', nix_text, re.S)

def test_backend_process_depends_on_db_and_env(nix_text):
    assert re.search(r'processes\.backend\.exec\s*=\s*"uv run uvicorn fushigi_backend\.main:app --reload --host 0\.0\.0\.0"\s*;', nix_text)
    assert re.search(r'processes\.backend\.process-compose\s*=\s*\{[^}]*environment\s*=\s*\[\s*"DATABASE_URL=postgres://postgres:postgres@localhost:5432/postgres"\s*\]', nix_text, re.S)
    assert re.search(r'processes\.backend\.process-compose\.depends_on\.generate-default-db\.condition\s*=\s*"process_completed_successfully"\s*;', nix_text)

# -----------------------------
# Additional configuration
# -----------------------------

def test_git_hooks_excludes_and_python_quality_hooks(nix_text):
    assert re.search(r'git-hooks\.excludes\s*=\s*\[\s*"\.\*srs\.py"\s*\]\s*;', nix_text)
    for key in [
        r'mypy',
        r'ruff',
        r'taplo',
        r'check-builtin-literals',
        r'check-docstring-first',
        r'check-python',
        r'python-debug-statements',
    ]:
        if key == "mypy":
            assert re.search(r'mypy\s*=\s*\{[^}]*enable\s*=\s*true[^}]*entry\s*=\s*"uv run mypy"\s*;', nix_text, re.S)
        else:
            assert re.search(rf'{re.escape(key)}\.enable\s*=\s*true\s*;', nix_text)

def test_oci_hooks(nix_text):
    assert re.search(r'hadolint\.enable\s*=\s*true\s*;', nix_text)
    assert re.search(r'yamllint\.enable\s*=\s*true\s*;', nix_text)

def test_darwin_swift_setup(nix_text):
    assert re.search(r'\(lib\.mkIf pkgs\.stdenv\.isDarwin \{', nix_text)
    assert re.search(r'languages\.swift\.enable\s*=\s*true\s*;', nix_text)
    assert re.search(r'swiftlint\s*=\s*\{[^}]*enable\s*=\s*true[^}]*entry\s*=\s*"\$\{pkgs\.swiftlint\}/bin/swiftlint"\s*;', nix_text, re.S)
    assert re.search(r'swiftformat\s*=\s*\{[^}]*enable\s*=\s*true[^}]*entry\s*=\s*"\$\{pkgs\.swiftformat\}/bin/swiftformat"\s*;', nix_text, re.S)

# -----------------------------
# Sanity checks
# -----------------------------

def test_file_is_nix_module(nix_text):
    # Lightweight sanity: looks like a Nix function returning config via mkMerge
    assert "{ pkgs," in nix_text.replace("\\n", " ")
    assert "lib.mkMerge" in nix_text
    assert "config =" in nix_text
