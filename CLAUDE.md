# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Boxy is an Elixir library (currently in early development). The project uses Mix as its build tool and follows standard Elixir project conventions.

## Common Commands

### Dependencies
```bash
mix deps.get          # Install dependencies
mix deps.compile      # Compile dependencies
```

### Testing
```bash
mix test              # Run Boxy tests only
mix test <file>       # Run a specific test file
mix test <file>:<line> # Run a specific test at line number
mix boxy.test.all     # Run Boxy tests + test app tests via test app's test alias
```

**Note**: The test app in `tmp/test_app` has a `test` alias that runs both Boxy's tests and its own tests. Running `mix boxy.test.all` creates the test app if needed and runs `mix test` inside it.

### Code Quality
```bash
mix format            # Format all Elixir code according to .formatter.exs
mix format --check-formatted # Check if code is formatted without changing files
```

### Compilation
```bash
mix compile           # Compile the project
mix clean             # Remove compilation artifacts
```

### Interactive Shell
```bash
iex -S mix            # Start IEx with the project loaded
```

## Architecture

This is a fresh Elixir project with a standard structure:
- `lib/` - Main source code (currently contains only the `Boxy` module)
- `test/` - Test files using ExUnit
- `mix.exs` - Project configuration and dependencies
- `tmp/` - Directory for test apps during development (gitignored)

The project targets Elixir ~> 1.18 and includes the `:logger` application.

## Development Conventions

- **Test Apps**: Always create test applications in the `tmp/` directory (e.g., `tmp/test_app`). This keeps test artifacts separate from the main codebase and is already configured in `.gitignore`.

## Pre-Commit Hook

This repository has a pre-commit hook that runs `mix precommit`, which executes:
1. `mix boxy.pedant` - Ensures all directories have CLAUDE.md files
2. `mix format --check-formatted` - Verifies code formatting
3. `mix test.all` - Runs both Boxy tests and test app tests (if tmp/test_app exists)

The hook prevents commits if any of these checks fail.
