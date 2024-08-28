defmodule GqlBuilder.Formatter do
  # two spaces
  @single_indent "  "

  @spec indent(text :: String.t(), indent_level :: pos_integer()) :: String.t()
  def indent(text, indent_level)
      when is_binary(text) and is_integer(indent_level) and indent_level > -1 do
    make_indent(indent_level) <> text
  end

  @spec to_gql_name(name :: atom() | String.t()) :: String.t()
  def to_gql_name(atom) when is_atom(atom), do: to_gql_name(Atom.to_string(atom))

  def to_gql_name(text) when is_binary(text) do
    case String.split(text, "_") do
      [^text] ->
        text

      [first | rest] ->
        Enum.join([first | Enum.map(rest, &String.capitalize(&1))])
    end
  end

  @spec to_gql_type(name :: atom() | String.t()) :: String.t()
  def to_gql_type(atom) when is_atom(atom), do: to_gql_type(Atom.to_string(atom))

  def to_gql_type(text) when is_binary(text) do
    String.split(text, "_")
    |> Enum.map(&String.capitalize(&1))
    |> Enum.join()
  end

  @spec to_gql_enum(name :: atom() | String.t()) :: String.t()
  def to_gql_enum(atom) when is_atom(atom), do: to_gql_enum(Atom.to_string(atom))

  def to_gql_enum(text) when is_binary(text) do
    String.split(text, "_") |> Enum.map(&String.upcase(&1)) |> Enum.join("_")
  end

  def to_gql_value(text) when is_binary(text), do: "\"#{text}\""
  def to_gql_value(n) when is_number(n), do: "#{n}"
  def to_gql_value(b) when is_boolean(b), do: "#{b}"
  def to_gql_value(a) when is_atom(a), do: to_gql_enum(a)

  defp make_indent(0), do: ""

  defp make_indent(indent_level) do
    Enum.map(1..indent_level, fn _ -> @single_indent end) |> Enum.join()
  end
end
