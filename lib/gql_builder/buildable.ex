defprotocol GqlBuilder.Buildable do
  @moduledoc """
  The GqlBuilder.Generate protocol is responsible for
  converting a structure to a valid GraphQL fragment.
  """
  @spec build(t(), integer()) :: String.t()
  def build(term, indent)
end
