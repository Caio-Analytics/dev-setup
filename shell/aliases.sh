# dbt / DuckDB
alias dbtb='dbt build'
alias dbtr='dbt run'
alias dbtt='dbt test'
alias dbtdocs='dbt docs generate --static && dbt docs serve'

# Opens the local DuckDB warehouse dbt built, ready to query.
# Usage: ddb path/to/warehouse.duckdb
ddb() {
  duckdb "${1:-target/warehouse.duckdb}"
}

# Python / venv
alias venvon='source .venv/bin/activate'
alias venvnew='python3 -m venv .venv && source .venv/bin/activate && pip install --upgrade pip'

# Quality gate before a commit: lint + test in one shot.
check() {
  ruff check . && pytest
}

# git
alias gs='git status -sb'
alias gl='git graph'
