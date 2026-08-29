# dev-setup

Meu ambiente de trabalho pra dado: VS Code, shell e o esqueleto de projeto que reaproveito em tudo que construo (Recon, Bateia). Um comando deixa uma máquina Linux nova pronta pra trabalhar, sem configurar cada peça na mão de novo.

<!-- TODO: print ou GIF do terminal + VS Code configurados -->

## O que tem aqui

```
dev-setup/
├── install.sh                    # aplica tudo, idempotente
├── vscode/
│   ├── settings.json              # config real do editor
│   └── extensions.json            # extensões, também funciona como
│                                   # recomendação de workspace em
│                                   # qualquer projeto (.vscode/extensions.json)
├── git/
│   └── gitconfig                  # aliases + auth via gh CLI
├── shell/
│   └── aliases.sh                 # atalho pra dbt, DuckDB, venv, lint+test
└── templates/
    └── data-project/              # esqueleto de projeto novo
        ├── pyproject.toml          # ruff configurado
        ├── .pre-commit-config.yaml
        └── tests/
```

## Uso

```bash
git clone https://github.com/Caio-Analytics/dev-setup.git
cd dev-setup
./install.sh
```

O script cria link simbólico pro `settings.json` e pro `gitconfig`, adiciona uma linha no `.bashrc` carregando os aliases, e instala as extensões do VS Code que ainda não estiverem presentes. Roda de novo sem problema, qualquer arquivo que já exista é copiado com sufixo `.bak.<timestamp>` antes do link ser criado, nada é sobrescrito sem backup.

Pra começar um projeto novo a partir do template:

```bash
cp -r templates/data-project meu-projeto-novo
cd meu-projeto-novo
python3 -m venv .venv && source .venv/bin/activate
pip install -e ".[dev]"
pre-commit install
```

## Por que existe

Cada projeto novo (Recon, Bateia) começava com a mesma pergunta: qual linter, qual config de teste, qual extensão. Isso aqui é a resposta escrita uma vez, não decidida de novo a cada repositório.

## Alternativa

Se preferir gerenciar os links via [GNU Stow](https://www.gnu.org/software/stow/) em vez do `install.sh`, a estrutura de pastas já é compatível (`stow vscode git shell` a partir da raiz do repo, apontando `--target` pro `$HOME`).
