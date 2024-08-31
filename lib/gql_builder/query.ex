defmodule GqlBuilder.Query do
  alias GqlBuilder.Expr

  defstruct [:exprs]

  @type level :: integer()

  @type t :: %__MODULE__{
          exprs: [Expr.t()]
        }

  @spec new(Expr.expr_spec()) :: t()
  def new(spec) do
    %__MODULE__{exprs: [Expr.new(spec)]}
  end

  @spec add_expr(t(), Expr.t() | Expr.expr_spec(), level()) :: t()
  def add_expr(query, new_expr, location \\ 0)

  def add_expr(%__MODULE__{exprs: exprs} = query, %__MODULE__{} = new_expr, 0)
      when is_list(exprs) do
    %{query | exprs: exprs ++ [new_expr]}
  end

  def add_expr(%__MODULE__{exprs: exprs} = query, expr_spec, 0) when is_list(exprs) do
    %{query | exprs: exprs ++ [Expr.new(expr_spec)]}
  end

  def add_expr(%__MODULE__{exprs: exprs} = query, new_expr, level)
      when is_list(exprs) and level > 0 do
    target_level = level - 1

    updated =
      Enum.with_index(exprs)
      |> Enum.map(fn
        {expr, ^target_level} -> Expr.add_subexpr(expr, new_expr)
        {expr, _} -> expr
      end)

    %{query | exprs: updated}
  end
end

defimpl GqlBuilder.Buildable, for: GqlBuilder.Query do
  alias GqlBuilder.Formatter

  def build(query, indent) do
    body =
      Enum.map(query.exprs, fn expr -> GqlBuilder.Buildable.build(expr, indent + 1) end)
      |> Enum.join("\n")

    Formatter.indent("query {\n", indent) <> body <> Formatter.indent("\n}", indent)
  end
end
