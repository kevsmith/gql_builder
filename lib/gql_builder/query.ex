defmodule GqlBuilder.Query do
  alias GqlBuilder.Expr

  defstruct [:exprs]

  @type t :: %__MODULE__{
          exprs: [Expr.t()]
        }

  @spec new(Expr.t() | [Expr.t()]) :: t()
  def new(%Expr{} = expr) do
    %__MODULE__{exprs: [expr]}
  end

  def new(exprs) when is_list(exprs) do
    %__MODULE__{exprs: exprs}
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
