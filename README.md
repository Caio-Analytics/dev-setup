# dev-setup

A portable, privacy-safe starting point for data projects: VS Code recommendations, Git aliases, shell shortcuts, and a Python project template. It is designed for Linux and Windows without overwriting existing personal configuration.

## What is included

```
dev-setup/
├── install.sh                    # Linux setup
├── install.ps1                   # Windows setup
├── vscode/                       # VS Code settings and extension recommendations
├── git/gitconfig                 # shareable Git defaults and aliases only
├── shell/aliases.sh              # Bash shortcuts for dbt, DuckDB, Python, and tests
└── templates/data-project/       # Python data-project starter
```

The repository deliberately contains no Git identity, e-mail address, token, credential helper, machine path, or organization-specific setting. Configure your identity and GitHub authentication separately on each machine.

## Install

Clone the repository and run the installer for your operating system.

### Linux

```bash
git clone https://github.com/<your-account>/dev-setup.git
cd dev-setup
./install.sh
```

The Linux installer adds this repository as a Git config include, adds the Bash aliases to `~/.bashrc`, copies VS Code settings only when no settings file exists, and installs missing recommended extensions.

### Windows

Open PowerShell in the cloned directory:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\install.ps1
```

Use `-SkipExtensions` to only configure Git and VS Code settings. The Windows installer adds the Git include, copies settings only when none exist, and installs missing extensions. It does not modify your PowerShell profile.

## Existing configuration

Nothing is overwritten. If VS Code already has a `settings.json`, the installer leaves it intact and prints the path to this repository's settings file for manual review. Git aliases are added through `include.path`, so your existing global Git configuration remains in place.

To remove the Git aliases later:

```bash
git config --global --unset-all include.path "$(pwd)/git/gitconfig"
```

On Linux, remove the marked `dev-setup aliases` block from `~/.bashrc` if you no longer want the Bash shortcuts.

## Start a new data project

```bash
cp -r templates/data-project my-data-project
cd my-data-project
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
pre-commit install
```

The template targets Python 3.12+ and includes Ruff, pytest, and pre-commit.

## Notes

- `shell/aliases.sh` is Bash-specific; Windows users can use the project template and VS Code/Git setup, then add their preferred PowerShell functions.
- VS Code extension recommendations are also usable as `.vscode/extensions.json` in an individual repository.
- The settings and extension list are intentionally opinionated. Treat them as a starting point, not a required standard.

## License

MIT. See [LICENSE](LICENSE).
