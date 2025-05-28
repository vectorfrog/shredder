defmodule Shredder.CommandTest do
  use ExUnit.Case
  alias Shredder.Command
  alias Shredder.Flag

  test "creates a new command" do
    f = fn _ -> :ok end
    assert Command.new("run", description: "runs the script", handler: f) == %Command{name: :run, description: "runs the script", handler: f}
  end

  test "creates a command with flags" do
    f = fn _ -> :ok end
    flags = [Flag.new("flag", alias: "f", description: "the flag")]
    assert Command.new("run", description: "runs the script", handler: f, flags: flags) == %Command{
      name: :run,
      description: "runs the script",
      handler: f,
      flags: flags
    }
  end

  test "creates a command with subcommands" do
    f = fn _ -> :ok end
    subcommands = [Command.new("subcommand", description: "the subcommand", parent: :run)]
    assert Command.new("run", description: "runs the script", handler: f, subcommands: subcommands) == %Command{
      name: :run,
      description: "runs the script",
      handler: f,
      subcommands: subcommands
    }
  end

  test "dispatches command with parsed flags" do
    handler = fn flags -> {:ok, flags} end
    command = Command.new("run", handler: handler)
    parsed_flags = %{_base: ["run", "dmc"], verbose: true}

    assert Command.dispatch(command, parsed_flags) == {:ok, parsed_flags}
  end

  test "returns error when flags are invalid" do
    handler = fn flags -> {:ok, flags} end
    command = Command.new("run", handler: handler)
    invalid_flags = %{_valid?: false, errors: ["Invalid flags"]}

    assert Command.dispatch(command, invalid_flags) == {:error, ["Invalid flags"]}
  end

  test "can use an atom as the command name" do
    handler = fn flags -> {:ok, flags} end
    command = Command.new(:run, handler: handler)
    assert command.name == :run
  end

  test "create a default command" do
    assert Command.new(:default, handler: fn _ -> :ok end).name == :default
  end

end
