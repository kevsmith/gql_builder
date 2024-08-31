defmodule GqlBuilder.Expr do
  @type spec_option :: {:gql_type, atom()} | {:fields, [atom() | tuple()]} | {:args, Keyword.t()}
  @type spec :: [] | [spec_option()]
  @type t :: %__MODULE__{
          gql_type: atom(),
          fields: [atom() | tuple()],
          args: nil | Keyword.t()
        }
  @enforce_keys [:gql_type, :fields]
  defstruct [:args, :subexpr | @enforce_keys]

  @spec new(spec()) :: t()
  def new(spec) do
    gql_type = Keyword.get(spec, :gql_type)
    fields = Keyword.get(spec, :fields)
    args = Keyword.get(spec, :args)
    %__MODULE__{gql_type: gql_type, fields: fields, args: args}
  end
end

defimpl GqlBuilder.Buildable, for: GqlBuilder.Expr do
  alias GqlBuilder.Formatter

  def build(expr, indent) do
    name = maybe_add_args(Formatter.to_gql_name(expr.gql_type), expr.args)
    fields = generate_fields(expr.fields, indent + 1) |> Enum.join("\n")

    if expr.subexpr do
      subexpr = GqlBuilder.Buildable.build(expr.subexpr, indent + 1)

      Formatter.indent(
        [name <> " {", subexpr, fields, Formatter.indent("}", indent)] |> Enum.join("\n"),
        indent
      )
    else
      Formatter.indent(
        [name <> " {", fields, Formatter.indent("}", indent)] |> Enum.join("\n"),
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
