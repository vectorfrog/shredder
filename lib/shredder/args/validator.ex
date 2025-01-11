defmodule Shredder.Args.Validator do
  @moduledoc """
  Validates the parsed command-line arguments against the expected flags.
  """

  @doc """
  Validates the parsed command-line arguments against a list of flag specifications.

  This function performs several validation checks:
  - Required flags are present
  - Flag values meet their type requirements
  - Flag dependencies are satisfied
  - No conflicting flags are present together
  - Positional arguments are in correct positions

  ## Parameters
    * `parsed` - A map containing the parsed command-line arguments where keys are flag names
      and values are the actual values (from Parser.parse/1)
    * `flags` - A list of Flag structs defining the expected flags and their requirements

  ## Returns
  A map containing:
    * The validated values with their proper types
    * `_valid?` - Boolean indicating if all validations passed
    * `errors` - List of error messages if any validations failed

  ## Examples

      iex> flags = [Flag.new(:file, type: :string, required: true)]
      iex> parsed = %{file: "test.txt"}
      iex> Validator.validate_parsed(parsed, flags)
      %{file: "test.txt", _valid?: true, errors: []}
  """
  def validate_parsed(parsed, flags) do
    # Remove "run" from base args if present
    parsed = case Map.get(parsed, :_base) do
      ["run" | rest] -> Map.put(parsed, :_base, rest)
      _ -> parsed
    end

    # Process aliases
    parsed = process_aliases(parsed, flags)

    # Process positional arguments
    {parsed, positional_errors} = process_positional_args(parsed, flags)

    # Validate remaining flags
    errors = []
      |> Enum.concat(positional_errors)
      |> validate_required_flags(parsed, flags)
      |> validate_types(parsed, flags)
      |> validate_dependencies(parsed, flags)
      |> validate_conflicts(parsed, flags)
      |> validate_values(parsed, flags)

    if Enum.empty?(errors) do
      # Only include valid values in the result
      result = flags
        |> Enum.filter(&(Map.has_key?(parsed, &1.name)))
        |> Enum.reduce(%{}, fn flag, acc ->
          value = convert_type(parsed[flag.name], flag.type)
          Map.put(acc, flag.name, value)
        end)

      result
      |> Map.put(:_valid?, true)
      |> Map.put(:errors, [])
    else
      # Return validated flags with errors
      result = flags
        |> Enum.filter(&(Map.has_key?(parsed, &1.name)))
        |> Enum.reduce(%{}, fn flag, acc ->
          value = parsed[flag.name]
          error = get_error_for_flag(flag.name, errors)
          flag = %{flag | value: value, valid?: error == nil, error: error}
          Map.put(acc, flag.name, flag)
        end)

      result
      |> Map.put(:_valid?, false)
      |> Map.put(:errors, errors)
    end
  end

  defp get_error_for_flag(flag_name, errors) do
    Enum.find_value(errors, fn error ->
      if String.contains?(error, "--#{flag_name}"), do: error
    end)
  end

  defp process_aliases(parsed, flags) do
    Enum.reduce(flags, parsed, fn flag, acc ->
      case find_alias_value(parsed, flag) do
        nil -> acc
        {_alias, value} -> Map.put(acc, flag.name, value)
      end
    end)
  end

  defp find_alias_value(parsed, flag) do
    aliases = [flag.alias | flag.aliases]
    |> Enum.map(fn
      nil -> nil
      a when is_binary(a) -> String.to_atom(a)
      a -> a
    end)

    Enum.find_value(aliases, fn a ->
      if a && Map.has_key?(parsed, a), do: {a, parsed[a]}
    end)
  end

  defp process_positional_args(parsed, flags) do
    base_args = Map.get(parsed, :_base, [])
    positional = Enum.sort_by(Enum.filter(flags, & &1.position), & &1.position)

    {result, errors} = Enum.reduce(positional, {parsed, []}, fn flag, {acc, errs} ->
      pos = flag.position - 1
      cond do
        length(base_args) <= pos ->
          {acc, errs ++ ["Required positional argument :#{flag.name} is missing in position #{flag.position}"]}
        true ->
          value = Enum.at(base_args, pos)
          {Map.put(acc, flag.name, value), errs}
      end
    end)

    {Map.delete(result, :_base), errors}
  end

  defp convert_type(value, :boolean) when is_boolean(value), do: value
  defp convert_type(_value, :boolean), do: true
  defp convert_type(value, :integer) when is_binary(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> value
    end
  end
  defp convert_type(value, :string) when is_binary(value), do: value
  defp convert_type(value, _), do: value

  defp validate_required_flags(errors, parsed, flags) do
    missing = Enum.filter(flags, fn flag ->
      flag.required && !flag.position && !Map.has_key?(parsed, flag.name)
    end)

    case missing do
      [] -> errors
      flags -> errors ++ Enum.map(flags, &"Required flag --#{&1.name} is missing")
    end
  end

  defp validate_types(errors, parsed, flags) do
    invalid = Enum.filter(flags, fn flag ->
      Map.has_key?(parsed, flag.name) && !valid_type?(parsed[flag.name], flag)
    end)

    case invalid do
      [] -> errors
      flags -> errors ++ Enum.map(flags, fn flag ->
        case flag.type do
          :integer -> "Expected integer, got '#{parsed[flag.name]}'"
          _ -> "Invalid value for --#{flag.name}: #{parsed[flag.name]}"
        end
      end)
    end
  end

  defp valid_type?(value, %{type: :boolean}) when is_boolean(value), do: true
  defp valid_type?(_value, %{type: :boolean}), do: true
  defp valid_type?(value, %{type: :integer}) when is_binary(value) do
    case Integer.parse(value) do
      {_int, ""} -> true
      _ -> false
    end
  end
  defp valid_type?(value, %{type: :string}) when is_binary(value), do: true
  defp valid_type?(_value, _flag), do: false

  defp validate_dependencies(errors, parsed, flags) do
    missing_deps = Enum.filter(flags, fn flag ->
      Map.has_key?(parsed, flag.name) &&
      Enum.any?(flag.depends_on, fn dep -> !Map.has_key?(parsed, dep) end)
    end)

    case missing_deps do
      [] -> errors
      flags -> errors ++ Enum.map(flags, fn flag ->
        dep = hd(flag.depends_on)
        "Flag --#{dep} is required for --#{flag.name}"
      end)
    end
  end

  defp validate_conflicts(errors, parsed, flags) do
    conflicts = Enum.filter(flags, fn flag ->
      Map.has_key?(parsed, flag.name) &&
      Enum.any?(flag.conflicts_with, fn conflict -> Map.has_key?(parsed, conflict) end)
    end)

    case conflicts do
      [] -> errors
      flags -> errors ++ Enum.map(flags, fn flag ->
        conflict = hd(flag.conflicts_with)
        "Flag --#{flag.name} conflicts with --#{conflict}"
      end)
    end
  end

  defp validate_values(errors, parsed, flags) do
    invalid = Enum.filter(flags, fn flag ->
      values = flag.values
      Map.has_key?(parsed, flag.name) &&
      length(values) > 0 &&
      !Enum.member?(values, parsed[flag.name])
    end)

    case invalid do
      [] -> errors
      flags -> errors ++ Enum.map(flags, &"Invalid value for --#{&1.name}: #{parsed[&1.name]}")
    end
  end
end
