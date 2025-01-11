defmodule Shredder.Command do
  @moduledoc """
  Represents a command in the shredder system.
  """

  defstruct [
    name: nil,
    description: nil,
    flags: [],
    handler: nil,
    parent: false,
    subcommands: []
  ]

  def new(name, opts \\ []) do
    name = if is_binary(name), do: String.to_atom(name), else: name
    opts = Keyword.merge([name: name], opts)
    struct!(__MODULE__, opts)
  end

  @doc """
  Dispatches parsed command-line arguments to the appropriate handler function.

  This function takes a Command struct and parsed flags as input. It first checks if
  the parsed flags are valid. If they are not valid, it returns an error tuple with
  the validation errors. If the flags are valid, it calls the command's handler
  function with the parsed flags as an argument.

  ## Parameters
    * `command` - A Command struct containing the handler and other command information
    * `parsed_flags` - A map of parsed command-line arguments.

  ## Returns
    A tuple indicating the result of the dispatch operation. The tuple can be either
    {:ok, result} or {:error, reason}. The result is the return value of the handler
    function if the dispatch is successful. The reason is a string or a list of strings
    indicating the error if the dispatch fails.
  """
  def dispatch(%__MODULE__{} = command, parsed_flags) do
    case parsed_flags do
      %{_valid?: false} -> {:error, parsed_flags.errors}
      flags -> command.handler.(flags)
    end
  end
end
