defmodule Shredder.Flag do
 @moduledoc """
 Defines command-line flag structures and utilities.
 Used for parsing and validating CLI arguments with support for
 type checking, dependencies, and conflict resolution.
 """

 @enforce_keys [:name]
 defstruct [
   :name,
   :alias,
   :description,
   :type,
   :validate,
   :value,
   :error,
   :position,
   aliases: [],
   values: [],
   valid?: true,
   conflicts_with: [],
   depends_on: [],
   required: false,
   multiple: false,
   default: nil
 ]

 @doc """
 Creates a new Flag struct.

 ## Parameters
   * `name` - Required. The primary name of the flag (e.g. "file")
   * `opts` - Optional keyword list of flag attributes

 ## Options
   * `:alias` - Short form of the flag
   * `:aliases` - List of alternative names for the flag
   * `:description` - Help text for the flag
   * `:type` - Data type (:string, :integer, :boolean, etc)
   * `:required` - Whether flag must be provided
   * `:multiple` - Whether flag can be used multiple times
   * `:default` - Default value if not provided
   * `:validate` - Optional validation function
   * `:values` - List of valid values for the flag
   * `:conflicts_with` - List of incompatible flags
   * `:depends_on` - List of required companion flags
   * `:position` - Position of the flag in the command line arguments.
     This is useful for commands like `run file1 file2` where `file1` and `file2` are positional flags.

 ## Example
     Flag.new("file",
       alias: "f",
       aliases: ["input"],
       description: "input file path",
       type: :string,
       values: ["file1", "file2"]
     )
 """
 def new(name, opts \\ []) do
   name = if is_binary(name), do: String.to_atom(name), else: name
   opts = Keyword.update(opts, :alias, nil, fn
     nil -> nil
     a when is_binary(a) -> String.to_atom(a)
     a -> a
   end)

   opts = Keyword.merge([name: name], opts)
   struct!(__MODULE__, opts)
 end
end
