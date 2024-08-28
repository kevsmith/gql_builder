defmodule GqlBuilder.FormatterTest do
  use ExUnit.Case, async: true

  alias GqlBuilder.Formatter

  test "simple test indentation" do
    assert "hello" == Formatter.indent("hello", 0)
    assert "  hello" == Formatter.indent("hello", 1)
    assert "    hello" == Formatter.indent("hello", 2)
    assert "        hello" == Formatter.indent("hello", 4)
    assert "    " == Formatter.indent("", 2)
  end

  test "invalid indent level raises error" do
    assert_raise(FunctionClauseError, fn -> Formatter.indent("hello", -1) end)
    assert_raise(FunctionClauseError, fn -> Formatter.indent("hello", 1.5) end)
  end

  test "converting Elixir snake case to GraphQL camel case names" do
    assert "myLittlePony" == Formatter.to_gql_name(:my_little_pony)
    assert "myLittlePony" == Formatter.to_gql_name("my_little_pony")
    assert "blackRainbow" == Formatter.to_gql_name(:black_rainbow)
    assert "blackRainbow" == Formatter.to_gql_name(:blackRainbow)
    assert "black-Rainbow" == Formatter.to_gql_name(:"black-_rainbow")
  end

  test "converting Elixir snake case to GraphQL capitalized camel case type names" do
    assert "MyLittlePony" == Formatter.to_gql_type(:my_little_pony)
    assert "MyLittlePony" == Formatter.to_gql_type("my_little_pony")
    assert "BlackRainbow" == Formatter.to_gql_type(:black_Rainbow)
    assert "Blackrainbow" == Formatter.to_gql_type(:blackRainbow)
    assert "Black-Rainbow" == Formatter.to_gql_type(:"black-_rainbow")
  end

  test "converting Elixir snake case to GraphQL all caps enum names" do
    assert "RED" == Formatter.to_gql_enum(:red)
    assert "BLUE" == Formatter.to_gql_enum("blue")
    assert "PASS_FAIL" == Formatter.to_gql_enum(:pass_fail)
    assert "PASS_FAIL" == Formatter.to_gql_enum("pass_fail")
  end
end
