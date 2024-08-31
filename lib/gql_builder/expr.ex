defmodule GqlBuilder.Expr do
  @enforce_keys [:gql_type]
  defstruct [:args, :fields, :subexprs | @enforce_keys]

  @type gql_type_option :: {:gql_type, atom()}
  @type fields_option :: {:fields, [atom() | tuple()]}
  @type args_option :: {:args, Keyword.t()}
  @type spec :: [] | [gql_type_option() | fields_option() | args_option()]
  @type subexpr_option :: {:subexpr, spec()}
  @type subexpr_spec :: [gql_type_option() | args_option() | subexpr_option()]
  @type expr_spec :: spec() | subexpr_spec()
  @type t :: %__MODULE__{
          gql_type: atom(),
          fields: nil | [atom() | tuple()],
          args: nil | Keyword.t(),
          subexprs: [] | [%__MODULE__{}]
        }

  @spec new(expr_spec()) :: t()
  def new(spec) do
    if has_subexpr?(spec) do
      new_subexpr(spec)
    else
      new_expr(spec)
    end
  end

  @spec add_subexpr(t(), t() | expr_spec()) :: t()
  def add_subexpr(%__MODULE__{subexprs: subexprs} = expr, %__MODULE__{} = new_expr) do
    %{expr | subexprs: subexprs ++ [new_expr]}
  end

  def add_subexpr(%__MODULE__{subexprs: subexprs} = expr, new_spec) do
    %{expr | subexprs: subexprs ++ [new(new_spec)]}
  end

  defp new_subexpr(spec) do
    gql_type = Keyword.get(spec, :gql_type)
    args = Keyword.get(spec, :args)
    subexpr = Keyword.get(spec, :subexpr)
    %__MODULE__{gql_type: gql_type, args: args, subexprs: [new(subexpr)]}
  end

  defp new_expr(spec) do
    gql_type = Keyword.get(spec, :gql_type)
    fields = Keyword.get(spec, :fields)
    args = Keyword.get(spec, :args)
    %__MODULE__{gql_type: gql_type, fields: fields, args: args, subexprs: []}
  end

  defp has_subexpr?(spec) do
    Keyword.has_key?(spec, :subexpr)
  end
end

defimpl GqlBuilder.Buildable, for: GqlBuilder.Expr do
  alias GqlBuilder.Formatter

  def build(expr, indent) do
    name = maybe_add_args(Formatter.to_gql_name(expr.gql_type), expr.args)

    if Enum.empty?(expr.subexprs) do
      fields = generate_fields(expr.fields, indent + 1) |> Enum.join("\n")

      Formatter.indent(
        [name <> " {", fields, Formatter.indent("}", indent)] |> Enum.join("\n"),
        indent
      )
    else
      subexprs =
        Enum.map(expr.subexprs, fn subexpr -> GqlBuilder.Buildable.build(subexpr, indent + 1) end)

      Formatter.indent(
        List.flatten([name <> " {", subexprs, Formatter.indent("}", indent)])
        |> Enum.join("\n"),
        indent
      )
    end
  end

  defp generate_fields(nil, _indent), do: []

  defp generate_fields(fields, indent) do
    Enum.map(fields, &generate_field(&1, indent))
  end

  defp generate_field({name, fields}, indent) do
    field = Formatter.indent(Formatter.to_gql_name(name), indent)
    fields = generate_fields(fields, indent + 1) |> Enum.join("\n")
    field <> " {\n" <> fields <> "\n" <> Formatter.indent("}", indent)
  end

  defp generate_field(name, indent) do
    Formatter.indent(Formatter.to_gql_name(name), indent)
  end

  defp maybe_add_args(type_name, nil), do: type_name

  defp maybe_add_args(type_name, args) do
    args = Enum.map(args, &generate_arg(&1)) |> Enum.join(", ")
    type_name <> "(" <> args <> ")"
  end

  defp generate_arg({name, value}) do
    Formatter.to_gql_name(name) <> ": " <> Formatter.to_gql_value(value)
  end
end
