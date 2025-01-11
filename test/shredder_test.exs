defmodule ShredderTest do
  use ExUnit.Case
  alias Shredder.Flag
  alias Shredder.Command
  import ExUnit.CaptureIO

  test "run" do
    args = ["run", "--file", "file1"]
    commands = [
      Command.new("run",
        description: "run is a test command, it simply returns the flags in an ok tuple",
        flags: [Flag.new(:file, type: :string, required: true, position: 1)],
        handler: fn flags -> {:ok, flags} end
      )
    ]
    assert Shredder.shred(args, commands) == {:ok, %{file: "file1"}}
  end

  test "run with positional arguments" do
    args = ["run", "file1", "file2"]
    commands = [
      Command.new("run",
        description: "run is a test command, it simply returns the flags in an ok tuple",
        flags: [
          Flag.new(:input_file, type: :string, required: true, position: 1),
          Flag.new(:output_file, type: :string, required: true, position: 2),
        ],
        handler: fn flags -> {:ok, flags} end
      )
    ]
    assert Shredder.shred(args, commands) == {:ok, %{input_file: "file1", output_file: "file2"}}
  end

  test "fail with no matching command" do
    args = ["fun"]
    commands = [
      Command.new("run",
        description: "run is a test command, it simply returns the flags in an ok tuple",
        flags: [Flag.new(:file, type: :string, required: true, position: 1)],
        handler: fn flags -> {:ok, flags} end
      )
    ]
    assert capture_io(fn ->
      Shredder.shred(args, commands)
    end) == "No matching command found for 'fun'"
  end

end
