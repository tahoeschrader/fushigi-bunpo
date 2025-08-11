{
  pkgs,
  lib,
  config,
  ...
}: {
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
          ((pkgs.formats.toml {}).generate "statix.toml" {
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
      packages = with pkgs; [
        # why do i have to put in this clooge if uv installs it...
        python3Packages.psycopg
      ];
      services.adminer.enable = true;
      # TODO populate database with db-tools
      services.postgres.enable = true;
      services.postgres.initialDatabases = lib.toList {
        name = "postgres";
        user = "postgres";
        pass = "postgres";
      };
      processes.adminer.process-compose.depends_on.postgres.condition = "process_healthy";
      processes.backend.exec = "uv run uvicorn fushigi_backend.main:app --reload --host 0.0.0.0";
      processes.backend.process-compose = {
        environment = ["DATABASE_URL=postgres://postgres:postgres@localhost:5432/postgres"];
        depends_on.postgres.condition = "process_healthy";
        working_dir = "./backend";
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
      processes.frontend.exec = let
        # Localhost won't work when testing on another device
        getIpCmd = pkg: "${pkg}/bin/ip route get 1 | ${pkgs.gnused}/bin/sed 's/^.*src \\([^ ]*\\).*$/\\1/;q'";
        pkg =
          if pkgs.stdenv.isLinux
          then pkgs.iproute2
          else if pkgs.stdenv.isDarwin
          then pkgs.iproute2mac
          else throw "${pkgs.stdenv.system} not supported";
      in ''
        export VITE_API_BASE="http://$(${getIpCmd pkg}):8000"
        bun run dev --open
      '';
      processes.frontend.process-compose.working_dir = "./app";
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
        clippy.enable = true;
        rustfmt.enable = true;
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
      # NOTE: You must have Xcode installed locally.
      # This configuration assumes it's at /Applications/Xcode.app.
      # Required for SwiftLint/SwiftFormat to access sourcekitdInProc.framework.
      languages.swift.enable = true;
      git-hooks.hooks = {
        swiftlint = {
          enable = true;
          name = "SwiftLint";
          description = "Enforcing Swift style and conventions";
          files = "\\.swift$";
          entry = ''
            export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
            ${pkgs.swiftlint}/bin/swiftlint
          '';
        };
        swiftformat = {
          enable = true;
          name = "SwiftFormat";
          description = "Formatting Swift code with conventional style";
          files = "\\.swift$";
          entry = ''
            export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
            ${pkgs.swiftformat}/bin/swiftformat
          '';
        };
      };
    })
  ];
}
