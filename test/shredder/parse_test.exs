defmodule Shredder.ParseTest do
  use ExUnit.Case
  alias Shredder.Args.Parser

  test "parse processes a list of standard args" do
    args = ["file1", "file2"]
    assert Parser.parse(args) == %{_base: ["file1", "file2"]}
  end

  test "handles POSIX style space separated args" do
    args = ["-f", "file2"]
    assert Parser.parse(args) == %{f: "file2"}
    args = ["-t", "file2"]
    assert Parser.parse(args) == %{t: "file2"}
    args = ["-x", "file2"]
    assert Parser.parse(args) == %{x: "file2"}
    args = ["-gcf", "file2"]
    assert Parser.parse(args) == %{g: "file2", c: "file2", f: "file2"}
  end

  test "handles POSIX `-` style equals separated args, including concatenation" do
    args = ["-f=file2"]
    assert Parser.parse(args) == %{f: "file2"}
    args = ["-t=file2"]
    assert Parser.parse(args) == %{t: "file2"}
    args = ["-x=file2"]
    assert Parser.parse(args) == %{x: "file2"}
    args = ["-gcf=file2"]
    assert Parser.parse(args) == %{g: "file2", c: "file2", f: "file2"}
  end

  test "handles POSIX `--` style equals separated args, no concatenation" do
    args = ["--file=file2"]
    assert Parser.parse(args) == %{file: "file2"}
    args = ["--type=file2"]
    assert Parser.parse(args) == %{type: "file2"}
    args = ["--x=file2"]
    assert Parser.parse(args) == %{x: "file2"}
    args = ["--gcf=file2"]
    assert Parser.parse(args) == %{gcf: "file2"}
  end

  test "handles MIXED style args" do
    args = ["-f", "--file=file2"]
    assert Parser.parse(args) == %{f: true, file: "file2"}
    args = ["run", "--file=file2"]
    assert Parser.parse(args) == %{_base: ["run"], file: "file2"}
    args = ["fun", "run", "--file=file2"]
    assert Parser.parse(args) == %{_base: ["fun", "run"], file: "file2"}
    args = ["fun", "run", "--file", "file2"]
    assert Parser.parse(args) == %{_base: ["fun", "run"], file: "file2"}
    args = ["fun", "run", "--file", "file2", "-gcf"]
    assert Parser.parse(args) == %{_base: ["fun", "run"], file: "file2", g: true, c: true, f: true}
    args = ["fun", "run", "--file", "file1", "-gcf", "file2"]
    assert Parser.parse(args) == %{_base: ["fun", "run"], file: "file1", g: "file2", c: "file2", f: "file2"}
  end

end
