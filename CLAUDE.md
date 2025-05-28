# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Shredder - Elixir CLI Argument Parser Library

Shredder is an Elixir library that provides a robust and flexible command-line argument parser with POSIX-style flags, commands with subcommands, and comprehensive validation.

## Essential Commands

### Development
```bash
# Run tests
mix test

# Run specific test file
mix test test/shredder_test.exs

# Run tests with focus tag
mix test --only focus

# Format code
mix format

# Check formatting
mix format --check-formatted

# Install dependencies
mix deps.get

# Compile project
mix compile
```

## Architecture Overview

### Core Modules

1. **Shredder** (lib/shredder.ex): Main entry point that orchestrates the parsing flow
   - `shred/2` function handles the complete parsing pipeline
   - Integrates Parser, Validator, and Command dispatch
   - Handles error display through UI.Print module

2. **Command** (lib/shredder/command.ex): Defines command structures with handlers
   - Supports nested subcommands
   - Each command has a handler function that receives validated flags

3. **Flag** (lib/shredder/flag.ex): Defines flag specifications including:
   - Type validation (string, integer, boolean, etc.)
   - Dependencies and conflicts between flags
   - Custom validation functions
   - Positional argument support

4. **Args.Parser** (lib/shredder/args/parser.ex): Parses raw CLI arguments into structured data
   - Handles both short (-f) and long (--flag) formats
   - Supports positional arguments

5. **Args.Validator** (lib/shredder/args/validator.ex): Validates parsed arguments against flag specifications
   - Type checking
   - Dependency and conflict resolution
   - Custom validation execution

6. **UI.Print** (lib/shredder/ui/print.ex): Handles formatted output
   - Uses the Owl library for colored terminal output
   - Provides error and success message formatting

## Testing Patterns

- Tests use ExUnit with `import ExUnit.CaptureIO` for testing CLI output
- Test files mirror the lib structure (e.g., lib/shredder/command.ex → test/shredder/command_test.exs)
- Use `@tag :focus` to run specific tests with `mix test --only focus`

## Dependencies

- **owl** (~> 0.12): Terminal UI library for colored output
- Elixir ~> 1.17