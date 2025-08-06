{ pkgs, lib, config, ... }:
{
  config = lib.mkMerge [
    {
      # Defaults
      git-hooks.default_stages = ["pre-push" "manual"];
      git-hooks.hooks = {
        commitizen.enable = true;
        gitleaks = {
          enable = true;
          name = "gitleaks";
          description = "Gitleaks on entire project";
          entry = "${pkgs.gitleaks}/bin/gitleaks protect --redact";
        };
        lychee.enable = true;
        markdownlint.enable = true;
        markdownlint.settings.configuration.MD013.line_length = -1;
        mdsh.enable = true;
        tagref.enable = true;
        typos.enable = true;

        # pre-commit builtins
        check-added-large-files.enable = true;
        check-case-conflicts.enable = true;
        check-executables-have-shebangs.enable = true;
        check-merge-conflicts.enable = true;
        check-symlinks.enable = true;
        check-vcs-permalinks.enable = true;
        end-of-file-fixer.enable = true;
        fix-byte-order-marker.enable = true;
        forbid-new-submodules.enable = true;
        mixed-line-endings.enable = true;
        no-commit-to-branch.enable = true;
        no-commit-to-branch.settings.branch = ["main"];
        trim-trailing-whitespace.enable = true;
      };
    }
    {
      # Nix
      languages.nix.enable = true;
      git-hooks.hooks = {
        alejandra.enable = true;
        deadnix.enable = true;
        statix.enable = true;
        statix.raw.args = [
          "--config"
          ((pkgs.formats.toml { }).generate "statix.toml" {
            disabled = [
              "unquoted_uri"
              "repeated_keys"
            ];
          })
        ];
      };
    }
    {
      # Backend
      languages.python = {
        enable = true;
        uv.enable = true;
        uv.sync.enable = true;
      };
      git-hooks.hooks = {
        flake8.enable = true;
        mypy.enable = true;
        ruff.enable = true;
        taplo.enable = true;

        # pre-commit builtin hooks
        check-builtin-literals.enable = true;
        check-docstring-first.enable = true;
        check-python.enable = true;
        name-tests-test.enable = true;
        python-debug-statements.enable = true;
      };
    }
    {
      # SvelteKit frontend
      git-hooks.hooks.biome.enable = true;
      languages = {
        typescript.enable = true;
        javascript = {
          enable = true;
          directory = "./app";
          bun.enable = true;
          bun.install.enable = true;
        };
      };
    }
    {
      # TUI
      languages.rust.enable = true;
      git-hooks.hooks = {
        flake8.enable = true;
        mypy.enable = true;
        ruff.enable = true;
        taplo.enable = true;
      };
    }
    {
      # OCI
      git-hooks.hooks = {
        hadolint.enable = true;
        yamllint.enable = true;
      };
    }
    (lib.mkIf pkgs.stdenv.isDarwin {
      # SwiftUI app
      languages.swift.enable = true;
      git-hooks.hooks = {
        swiftlint = {
          enable = true;
          name = "SwiftLint";
          description = "Enforcing Swift style and conventions";
          files = "\\.swift$";
          entry = "${pkgs.swiftlint}/bin/swiftlint";
        };
        swiftformat = {
          enable = true;
          name = "SwiftFormat";
          description = "Formatting Swift code with conventional style";
          files = "\\.swift$";
          entry = "${pkgs.swiftformat}/bin/swiftformat";
        };
      };
    })
  ];
}
