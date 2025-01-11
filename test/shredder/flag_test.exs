defmodule Shredder.FlagTest do
  use ExUnit.Case, async: true
  alias Shredder.Flag

  test "converts strings to atoms" do
    expected_flag = %Shredder.Flag{
      name: :file,
      alias: :f,
      description: "input file path",
      type: :string,
      required: false,
      multiple: false,
      default: nil,
      validate: nil,
      conflicts_with: [],
      depends_on: [],
      position: nil
    }

    assert Shredder.Flag.new("file", alias: "f", description: "input file path", type: :string) == expected_flag
  end

  test "can create a new flag" do
    expected_flag = %Shredder.Flag{
      name: :file,
      alias: :f,
      description: "input file path",
      type: :string,
      required: false,
      multiple: false,
      default: nil,
      validate: nil,
      conflicts_with: [],
      depends_on: [],
      position: nil
    }

    assert Shredder.Flag.new(:file, alias: :f, description: "input file path", type: :string) == expected_flag
  end

  test "can create a boolean flag" do
    expected_flag = %Shredder.Flag{
      name: :case,
      alias: :c,
      description: "case sensitive",
      type: :boolean,
      required: false,
      multiple: false,
      default: nil,
      validate: nil,
      conflicts_with: [],
      depends_on: [],
      position: nil
    }

    assert Shredder.Flag.new(:case, alias: :c, description: "case sensitive", type: :boolean) == expected_flag
  end

  test "handles position in flag creation" do
    flag = Shredder.Flag.new(:file, position: 1)
    assert flag.position == 1

    flag_no_pos = Shredder.Flag.new(:file)
    assert flag_no_pos.position == nil
  end

end
