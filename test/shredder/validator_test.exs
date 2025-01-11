defmodule Shredder.ValidatorTest do
  use ExUnit.Case
  alias Shredder.Flag
  alias Shredder.Args.Validator
  alias Shredder.Args.Parser

  test "validate_result validates strings" do
    flags = [Flag.new(:file, type: :string)]
    parsed = Parser.parse(["run", "--file", "file1"])
    result = Validator.validate_parsed(parsed, flags)
    assert result == %{file: "file1", _valid?: true, errors: []}
  end

  test "validate_result validates ints" do
    flags = [Flag.new(:count, type: :integer)]
    parsed = Parser.parse(["run", "--count", "42"])
    result = Validator.validate_parsed(parsed, flags)
    assert result == %{count: 42, _valid?: true, errors: []}
  end

  test "validate_result validates booleans" do
    flags = [Flag.new(:verbose, type: :boolean)]
    parsed = Parser.parse(["run", "--verbose"])
    result = Validator.validate_parsed(parsed, flags)
    assert result == %{verbose: true, _valid?: true, errors: []}
  end

  test "validate_result validates required flags" do
    flags = [Flag.new(:file, type: :string, required: true)]
    parsed = Parser.parse(["run"])
    result = Validator.validate_parsed(parsed, flags)
    assert result == %{_valid?: false, errors: ["Required flag --file is missing"]}
  end

  test "validate_result validates aliases" do
    flags = [Flag.new(:file, type: :string, aliases: ["f"])]
    parsed = Parser.parse(["run", "--f", "file1"])
    result = Validator.validate_parsed(parsed, flags)
    assert result == %{file: "file1", _valid?: true, errors: []}
  end

  test "validate_result validates conflicts" do
    flags = [Flag.new(:file, type: :string, conflicts_with: [:verbose])]
    parsed = Parser.parse(["run", "--file", "file1", "--verbose"])
    result = Validator.validate_parsed(parsed, flags)
    assert result == %{_valid?: false, errors: ["Flag --verbose conflicts with --file"]}
  end

  test "validate_result validates dependencies" do
    flags = [Flag.new(:file, type: :string, depends_on: [:verbose])]
    parsed = Parser.parse(["run", "--file", "file1"])
    result = Validator.validate_parsed(parsed, flags)
    assert result == %{_valid?: false, errors: ["Flag --verbose is required for --file"]}
  end

  test "validate_result validates flag values" do
    flags = [Flag.new(:file, type: :string, values: ["file1", "file2"])]
    parsed = Parser.parse(["run", "--file", "file3"])
    result = Validator.validate_parsed(parsed, flags)
    assert result == %{_valid?: false, errors: ["Invalid value for --file: file3"]}
  end

  test "validate_result validates positional arguments" do
    flags = [Flag.new(:file, type: :string, required: true, position: 1)]
    parsed = Parser.parse(["run", "file1"])
    result = Validator.validate_parsed(parsed, flags)
    assert result == %{_valid?: true, errors: [], file: "file1"}
  end

  test "validate_result validates positional arguments with missing value" do
    flags = [Flag.new(:file, type: :string, required: true, position: 1)]
    parsed = Parser.parse(["run"])
    result = Validator.validate_parsed(parsed, flags)
    assert result == %{_valid?: false, errors: ["Required positional argument :file is missing in position 1"]}
  end
end
