# Shredder

Shredder is an Elixir library designed to be integrated into your Elixir projects to quickly add powerful command-line interfaces. It provides a robust and flexible argument parser that handles POSIX-style flags, commands with subcommands, flag validation, dependencies, and conflict resolution.

## Purpose

Transform your Elixir applications into command-line tools by simply defining commands and flags. Shredder handles all the parsing, validation, and error reporting, allowing you to focus on your application's core functionality.

## Features

- POSIX-style short (-f) and long (--file) flags
- Command and subcommand support
- Type validation for flag values
- Flag dependencies and conflicts management
- Custom validation functions
- Default values
- Multiple value support
- Positional arguments
- Structured output

## Installation

Add `shredder` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:shredder, git: "git@github.com:vectorfrog/shredder.git"}
  ]
end
```

## Quick Start

### Integration Example

Create a CLI module in your existing Elixir project:

```elixir
defmodule MyApp.CLI do
  alias Shredder.{Command, Flag}

  def main(args) do
    # Define flags
    flags = [
      Flag.new(:input,
        alias: "i",
        description: "Input file path",
        type: :string,
        required: true
      ),
      Flag.new(:verbose,
        alias: "v",
        description: "Enable verbose output",
        type: :boolean,
        default: false
      )
    ]

    # Define command
    command = Command.new(:process,
      description: "Process input file",
      flags: flags,
      handler: &process_command/1
    )

    # Process arguments
    Shredder.shred(args, [command])
  end

  defp process_command(flags) do
    case flags do
      %{input: input, verbose: verbose} ->
        # Process the command...
        {:ok, %{status: "Processing #{input}", verbose: verbose}}
      _ ->
        {:error, "Invalid flags provided"}
    end
  end
end
```

Then call your CLI from an escript or Mix task:

```elixir
# In your escript main/1 function or Mix task
def main(args) do
  MyApp.CLI.main(args)
end
```

### Advanced Features

#### Flag Dependencies

```elixir
Flag.new(:output,
  alias: "o",
  description: "Output file",
  type: :string,
  depends_on: [:input]  # Requires --input flag
)
```

#### Flag Conflicts

```elixir
Flag.new(:quiet,
  alias: "q",
  description: "Suppress all output",
  type: :boolean,
  conflicts_with: [:verbose]  # Cannot be used with --verbose
)
```

#### Custom Validation

```elixir
Flag.new(:count,
  alias: "c",
  description: "Number of iterations",
  type: :integer,
  validate: fn value -> 
    if value > 0, do: :ok, else: {:error, "Count must be positive"}
  end
)
```

#### Multiple Values

```elixir
Flag.new(:tags,
  alias: "t",
  description: "Tags for processing",
  type: :string,
  multiple: true  # Allows multiple --tag arguments
)
```

#### Subcommands

```elixir
subcommand = Command.new(:validate,
  description: "Validate input file",
  flags: validation_flags,
  handler: &validate_command/1
)

main_command = Command.new(:process,
  description: "Process files",
  subcommands: [subcommand]
)
```

## Error Handling

Shredder provides detailed error messages for:
- Missing required flags
- Invalid flag values
- Flag conflicts
- Dependency violations
- Custom validation failures

Errors are returned as `{:error, reason}` tuples or printed directly to the console.

## License

This project is licensed under the MIT License.

