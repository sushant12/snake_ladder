defmodule SnakeLadder.Player do
  @moduledoc """
  Represents a player
  """
  alias __MODULE__

  defstruct [:id, :name, position: 1]

  # @type player :: :player1 | :player2
  @type t :: %Player{
          # id: player(),
          id: String.t(),
          name: String.t(),
          position: non_neg_integer()
        }

  @spec new(String.t()) :: t()
  def new(name) do
    params = %{
      id: name,
      name: name
    }

    struct!(Player, params)
  end
end
