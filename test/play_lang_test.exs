defmodule PlayLangTest do
  use ExUnit.Case
  doctest PlayLang

  test "greets the world" do
    assert PlayLang.hello() == :world
  end
end
