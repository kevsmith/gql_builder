defprotocol GqlBuilder.Buildable do
  @moduledoc """
  The GqlBuilder.Generate protocol is responsible for
  converting a structure to a valid GraphQL fragment.
  """
  @spec build(term(), pos_integer()) :: String.t()
  def build(term, indent)
end
