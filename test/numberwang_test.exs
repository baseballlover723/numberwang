defmodule NumberwangTest do
  use ExUnit.Case
  doctest Numberwang

  test "Numberwang isn't Wangernumb" do
    assert :"That's Numberwang" != "That's Wangernumb"
  end
end
