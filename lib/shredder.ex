defmodule Shredder do
  @moduledoc """
  Provides a utility for parsing and processing command-line arguments into a structured map.

  This module offers a way to define and parse command-line flags and arguments, including support for
  POSIX-style short and long flags, as well as standard commands without flags. It also includes features
  for validating flag values, handling dependencies and conflicts between flags, and more.

  The primary function, `shred/2`, takes a list of commands and flags as input and returns a structured map
  containing the parsed values. This map can be used to configure or execute specific actions based on the
  provided arguments.

  For more information on how to use this module, refer to the documentation for the `shred/2` function.
  """

  alias Shredder.Command
  alias Shredder.Flag
  alias Shredder.Args.Parser
  alias Shredder.Args.Validator
  alias Shredder.UI.Print

  defdelegate dispatch(command, parsed_flags), to: Shredder.Command, as: :dispatch

  @doc """
  Processes command line arguments against a list of defined commands or flags.

  ## Parameters
    * `args` - List of command line arguments
    * `commands` - List of Command structs defining available commands

  ## Returns
    * `{:ok, map()}` - On successful command execution
    * `%{_valid?: boolean(), ...}` - On direct flag parsing
    * Prints error message and returns nil on failure
  """
  @spec shred([String.t()], [Command.t()]) :: {:ok, map()} | map() | nil
  def shred(args, commands) do
    cond do
      Enum.empty?(args) ->
        IO.write("No command provided")
        nil

      true ->
        # Command-based parsing
        [cmd_name | _] = args
        case Enum.find(commands, fn cmd -> "#{cmd.name}" == cmd_name end) do
          nil ->
            IO.write("No matching command found for '#{cmd_name}'")
            nil

          command ->
            parsed = Parser.parse(args)
            validated = Validator.validate_parsed(parsed, command.flags)

            case validated do
              %{_valid?: true} = flags ->
                flags = Map.drop(flags, [:_valid?, :errors])
                case command.handler.(flags) do
                  {:ok, result} ->
                    Print.map(result)
                  {:error, message} ->
                    Print.red("Error during execution: #{message}")
                end
              %{errors: errors} ->
                Enum.each(errors, &Print.red/1)
                nil
            end
        end
    end
  end
end
