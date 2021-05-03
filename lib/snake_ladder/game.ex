defmodule SnakeLadder.Game do
  @moduledoc """
  Represents the game structure and exposes actions that can be taken to update it
  """
  alias __MODULE__
  alias SnakeLadder.Player

  defstruct players: [],
            token: nil,
            dice_state: nil,
            online_players: [],
            current_call: nil

  @type t :: %Game{
          players: list(Player.t()),
          token: String.t(),
          dice_state: non_neg_integer() | nil,
          online_players: list(Player.t()),
          current_call: Player.t() | nil
        }

  def new(token) do
    struct!(Game, token: token)
  end

  @spec add_player(t(), Player.t()) :: {:ok, t()}
  def add_player(game, player) do
    case find_player(game, player) do
      nil ->
        {:ok, Map.update!(game, :players, &[player | &1])}
      _ ->
        {:ok, game}
      end
  end

  defp find_player(game, player) do
    game.players
    |> Enum.find(&(&1.name == player.name))
  end
end
