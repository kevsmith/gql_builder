defmodule GqlBuilderTest do
  use ExUnit.Case
  doctest GqlBuilder

  test "greets the world" do
    assert GqlBuilder.hello() == :world
  end
end
