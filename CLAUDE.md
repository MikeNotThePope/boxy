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
mix test              # Run all tests
mix test <file>       # Run a specific test file
mix test <file>:<line> # Run a specific test at line number
```

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

The project targets Elixir ~> 1.18 and includes the `:logger` application.
