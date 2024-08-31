defmodule GqlBuilder do
  alias GqlBuilder.{Buildable, Expr, Query}
  @spec query(Expr.spec()) :: Query.t()
  def query(spec), do: Query.new(spec)

  @spec build(Buildable.t()) :: binary()
  def build(thing), do: build(thing, 0)

  @spec build(Buildable.t(), integer()) :: binary()
  def build(thing, indent) when indent > -1 do
    Buildable.build(thing, indent)
  end
end
