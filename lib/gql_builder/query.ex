defmodule GqlBuilder.Query do
  alias GqlBuilder.Expr

  defstruct [:exprs]

  @type t :: %__MODULE__{
          exprs: [Expr.t()]
        }

  @spec new(Expr.spec()) :: t()
  def new(spec) do
    %__MODULE__{exprs: [Expr.new(spec)]}
  end

  def add_expr(%__MODULE__{exprs: exprs} = expr, new_expr) do
    %{expr | exprs: exprs ++ [Expr.new(new_expr)]}
  end
end

defimpl GqlBuilder.Buildable, for: GqlBuilder.Query do
  alias GqlBuilder.Formatter

  def build(query, indent) do
    body =
      Enum.map(query.exprs, &GqlBuilder.Buildable.build(&1, indent + 1))
      |> Enum.join("\n")

    Formatter.indent("query {\n", indent) <> body <> Formatter.indent("\n}", indent)
  end
end
