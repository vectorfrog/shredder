defmodule Shredder.Args.Parser do
  @moduledoc """
  Parses command-line arguments into a structured map.
  """

  @doc """
  Processes a list of args into a structured map.

  This function takes a list of args and flags as input and returns a structured map
  containing the parsed values. It supports both POSIX-style short and long flags, including
  concatenation and equals-separated values. Additionally, it handles standard args
  without flags.

  ## Parameters
    * `args` - A list of strings representing the args and flags to be processed.

  ## Returns
    A map containing the parsed values of the args and flags. The map keys are the flag names
    or a special key :_base for standard args without flags.

  ## Examples
      iex> Shredder.Args.Parser.parse(["file1", "file2"])
      %{_base: ["file1", "file2"]}

      iex> Shredder.Args.Parser.parse(["-f", "file2"])
      %{f: "file2"}

      iex> Shredder.Args.Parser.parse(["--file=file2"])
      %{file: "file2"}
  """
  def parse(args \\ [])
  def parse([]), do: %{}

  def parse(args) do
    {base, acc} = process_args(args, {[], %{}}, 0)
    if Enum.empty?(base), do: acc, else: Map.put(acc, :_base, Enum.reverse(base))
  end

  defp process_args([], acc, _pos), do: acc

  # Handle POSIX `--` style flags, no concatenation
  defp process_args([<<"--", rest::binary>> | tail], {base, acc}, pos) do
    case String.split(rest, "=", parts: 2) do
      [flag, value] -> process_args(tail, {base, Map.put(acc, String.to_atom(flag), value)}, pos + 1)
      [flag] ->
        case tail do
          [<<"-", _::binary>> | _] ->
            process_args(tail, {base, Map.put(acc, String.to_atom(flag), true)}, pos + 1)
          [value | rest] ->
            process_args(rest, {base, Map.put(acc, String.to_atom(flag), value)}, pos + 1)
          [] ->
            process_args(tail, {base, Map.put(acc, String.to_atom(flag), true)}, pos + 1)
        end
    end
  end

  # Handle POSIX `-` style flags, allowing for concatenation
  defp process_args([<<"-", rest::binary>> | tail], {base, acc}, pos) do
    case String.split(rest, "=", parts: 2) do
      [flags, value] ->
        acc = Enum.reduce(String.graphemes(flags), acc, fn flag, map ->
          Map.put(map, String.to_atom(flag), value)
        end)
        process_args(tail, {base, acc}, pos + 1)
      [flags] ->
        case tail do
          [<<"-", _::binary>> | _] ->
            acc = Enum.reduce(String.graphemes(flags), acc, fn flag, map ->
              Map.put(map, String.to_atom(flag), true)
            end)
            process_args(tail, {base, acc}, pos + 1)
          [value | rest] ->
            acc = Enum.reduce(String.graphemes(flags), acc, fn flag, map ->
              Map.put(map, String.to_atom(flag), value)
            end)
            process_args(rest, {base, acc}, pos + 1)
          [] ->
            acc = Enum.reduce(String.graphemes(flags), acc, fn flag, map ->
              Map.put(map, String.to_atom(flag), true)
            end)
            process_args(tail, {base, acc}, pos + 1)
        end
    end
  end

  defp process_args([arg | tail], {base, acc}, pos) do
    process_args(tail, {[arg | base], acc}, pos + 1)
  end
end
