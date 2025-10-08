# Boxy

An opinionated Phoenix application generator that enforces best practices and integrates seamlessly with Claude Code.

## What is Boxy?

Boxy is a Mix task wrapper around `phx.new` that generates Phoenix applications with opinionated defaults and developer-friendly features out of the box. It's designed to get you building faster by making decisions for you while remaining compatible with the standard Phoenix ecosystem.

## Features

### 🎯 Opinionated Defaults

- **LiveView Always**: Every app is generated with LiveView enabled (`--live` flag)
- **PostgreSQL Database**: Standardized on PostgreSQL for consistency
- **Minimal Homepage**: Clean, blank starting page (no Phoenix marketing content)

### 🤖 Claude Code Integration

- **CLAUDE.md Files**: Automatically creates empty `CLAUDE.md` files in every non-gitignored directory
- **Smart Directory Scanning**: Uses `git check-ignore` to skip build artifacts and dependencies
- **Mix Task Included**: Generated apps include `mix boxy.pedant` for maintaining CLAUDE.md files

### ✅ Quality Assurance

- **Pre-commit Hook**: Automatically installed git hook that runs on every commit
  - Ensures all directories have CLAUDE.md files
  - Runs full test suite
  - **Blocks commits if tests fail**
- **Pre-commit Alias**: Run checks manually with `mix precommit`

### 🎨 Clean Defaults

- **No Marketing Pages**: Removes Phoenix's default homepage with logo and links
- **Standard Tailwind**: Maintains Phoenix's Tailwind CSS setup
- **Heroicons Integration**: Icons embedded via Tailwind plugin

## Installation

### Option 1: Mix Archive (Recommended)

```bash
mix archive.install github MikeNotThePope/boxy
```

### Option 2: Local Development

```bash
git clone https://github.com/MikeNotThePope/boxy.git
cd boxy
mix deps.get
mix archive.build
mix archive.install
```

## Usage

### Generate a New Phoenix App

```bash
mix boxy.new my_app
```

This will:
1. Generate a Phoenix app with LiveView and PostgreSQL
2. Initialize a git repository
3. Install the pre-commit hook
4. Copy the `boxy.pedant` task into your project
5. Create CLAUDE.md files in all directories
6. Replace the homepage with a blank template

### All Phoenix Options Supported

```bash
mix boxy.new my_app --module MyCustomModule
mix boxy.new my_app --no-mailer
mix boxy.new my_app --no-dashboard
```

**Note**: The `--live` and `--database` flags are automatically set and cannot be overridden.

### Maintain CLAUDE.md Files

After generating your app, you can ensure all new directories have CLAUDE.md files:

```bash
cd my_app
mix precommit
```

Or run the task directly:

```bash
mix boxy.pedant
```

## What Gets Generated

A standard Phoenix 1.7+ application with:

```
my_app/
├── .git/
│   └── hooks/
│       └── pre-commit          # Runs tests + boxy.pedant
├── assets/
│   ├── css/
│   ├── js/
│   └── tailwind.config.js
├── lib/
│   ├── mix/
│   │   └── tasks/
│   │       └── boxy.pedant.ex  # CLAUDE.md maintenance task
│   ├── my_app/
│   ├── my_app_web/
│   │   └── controllers/
│   │       └── page_html/
│   │           └── home.html.heex  # Minimal blank homepage
├── test/
├── CLAUDE.md                   # In every directory
├── mix.exs                     # With precommit alias
└── ...
```

## Pre-commit Hook

The installed git hook runs before every commit:

```bash
Running pre-commit checks...
→ Checking for CLAUDE.md files...
→ Running tests...
✓ All pre-commit checks passed
```

If tests fail:
```bash
→ Running tests...
❌ Tests failed. Commit aborted.
```

## Mix Tasks

### `mix boxy.new PATH`

Generate a new Phoenix application with Boxy's opinions.

### `mix boxy.pedant`

Scan all directories and create CLAUDE.md files where missing. Skips:
- Gitignored directories (via `git check-ignore`)
- The `.git` directory

Also available via alias:
```bash
mix precommit
```

## Configuration

### Customizing the Pre-commit Hook

Edit `.git/hooks/pre-commit` in your generated app to customize behavior.

### Disabling Features

Since Boxy wraps `phx.new`, you can still use Phoenix's flags:
- `--no-mailer` - Skip Swoosh mailer
- `--no-dashboard` - Skip LiveDashboard
- `--no-gettext` - Skip internationalization

## Philosophy

Boxy makes opinionated choices to reduce decision fatigue:

1. **LiveView by Default**: Modern Phoenix apps should use LiveView
2. **One Database**: PostgreSQL is the standard, no choice paralysis
3. **Code AI Ready**: CLAUDE.md files make your codebase AI-friendly
4. **Test Before Commit**: Broken tests shouldn't reach version control
5. **Clean Start**: No marketing fluff, just a blank canvas

## TODO

- [ ] Figure out how to make it work with DaisyUI
- [ ] Add option to customize default color palette
- [ ] Add option to customize fonts
- [ ] Explore Phoenix Auth integration with magic links
- [ ] Consider adding more Mix tasks for common operations
- [ ] Package as a proper Hex package

## Development

```bash
git clone https://github.com/MikeNotThePope/boxy.git
cd boxy
mix deps.get
mix test
```

## Contributing

This is currently an experimental project. Feel free to open issues or PRs!

## License

[CC0 1.0 Universal (CC0 1.0) Public Domain Dedication](https://creativecommons.org/public-domain/cc0/)

To the extent possible under law, the author has waived all copyright and related or neighboring rights to this work. You can copy, modify, distribute and perform the work, even for commercial purposes, all without asking permission.

## Credits

Built with [Claude Code](https://claude.com/claude-code) 🤖
