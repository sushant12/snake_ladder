defmodule SnakeLadder.Utils do
  @moduledoc false

  @doc """
  Generates a random short binary id.
  """
  @spec random_short_id() :: binary()
  def random_short_id do
    :crypto.strong_rand_bytes(5) |> Base.encode32()
  end
end
