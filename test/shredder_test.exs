defmodule ShredderTest do
  use ExUnit.Case
  doctest Shredder

  test "greets the world" do
    assert Shredder.hello() == :world
  end
end
