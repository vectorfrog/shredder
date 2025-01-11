defmodule Shredder.UI.PrintTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  describe "color output functions" do
    test "green/1 prints message in green" do
      output = capture_io(:stderr, fn ->
        Shredder.UI.Print.green("test message")
      end)
      assert output =~ "test message"
      assert output =~ "\e[32m" # green color code
    end

    test "red/1 prints message in red" do
      output = capture_io(:stderr, fn ->
        Shredder.UI.Print.red("test message")
      end)
      assert output =~ "test message"
      assert output =~ "\e[31m" # red color code
    end

    test "yellow/1 prints message in yellow" do
      output = capture_io(:stderr, fn ->
        Shredder.UI.Print.yellow("test message")
      end)
      assert output =~ "test message"
      assert output =~ "\e[33m" # yellow color code
    end

    test "cyan/1 prints message in cyan" do
      output = capture_io(:stderr, fn ->
        Shredder.UI.Print.cyan("test message")
      end)
      assert output =~ "test message"
      assert output =~ "\e[36m" # cyan color code
    end

    test "blue/1 prints message in blue" do
      output = capture_io(:stderr, fn ->
        Shredder.UI.Print.blue("test message")
      end)
      assert output =~ "test message"
      assert output =~ "\e[34m" # blue color code
    end
  end

  test "map/1 prints a map" do
      output = capture_io(:stderr, fn ->
        Shredder.UI.Print.map(%{id: 1, name: "John"})
      end)
      assert output =~
"""
┌──┬─────┐
│id│name │
├──┼─────┤
│1 │John │
└──┴─────┘
"""
    end
end
