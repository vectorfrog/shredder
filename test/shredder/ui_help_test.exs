defmodule Shredder.Ui.HelpTest do
  use ExUnit.Case
  alias Shredder.Ui.Help

  test "help" do
    assert Help.help() == "Help"
  end
end
