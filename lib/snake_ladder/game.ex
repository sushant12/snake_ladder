defmodule SnakeLadder.Game do
  @moduledoc """
  Represents the game structure and exposes actions that can be taken to update it
  """
  alias __MODULE__
  alias SnakeLadder.Player

  defstruct players: [],
            token: nil,
            dice_state: 0,
            online_players: [],
            current_call: nil

  @type t :: %Game{
          players: list(Player.t()),
          token: String.t(),
          dice_state: non_neg_integer(),
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

  @spec add_current_call(t(), Player.t()) :: {:ok, t()}
  def add_current_call(game, player) do
    player = find_player(game, player)
    {:ok, Map.update!(game, :current_call, fn _val -> player end)}
  end

  @spec roll_dice(t()) :: {:ok, t()}
  def roll_dice(game) do
    game =
      update_dice_state(game)
      |> update_player_position
      |> toggle_player_turn

    {:ok, game}
  end

  defp find_player(game, player) do
    game.players
    |> Enum.find(&(&1.name == player.name))
  end

  defp update_dice_state(game) do
    %{game | dice_state: Enum.random(1..6)}
  end

  defp update_player_position(game) do
    players =
      game.players
      |> Enum.map(fn player ->
        if player.name == game.current_call.name do
          Map.update!(player, :position, &(pain_or_pleasure(&1, game.dice_state)))
        else
          player
        end
      end)

    %{game | players: players}
  end

  defp toggle_player_turn(game) do
    players = game.players

    Map.update!(game, :current_call, fn current_call ->
      Enum.reject(players,&(&1.name == current_call.name))
      |> hd()
    end)
  end

  defp pain_or_pleasure(current_position, dice) do
    new_position = pain_or_pleasure(current_position + dice)
    if new_position > 100, do: current_position, else: new_position
  end
  defp pain_or_pleasure(2), do: 18
  defp pain_or_pleasure(4), do: 14
  defp pain_or_pleasure(9), do: 31
  defp pain_or_pleasure(13), do: 27
  defp pain_or_pleasure(17), do: 7
  defp pain_or_pleasure(20), do: 38
  defp pain_or_pleasure(28), do: 84
  defp pain_or_pleasure(29), do: 11
  defp pain_or_pleasure(40), do: 59
  defp pain_or_pleasure(51), do: 67
  defp pain_or_pleasure(54), do: 34
  defp pain_or_pleasure(62), do: 19
  defp pain_or_pleasure(63), do: 81
  defp pain_or_pleasure(64), do: 43
  defp pain_or_pleasure(71), do: 91
  defp pain_or_pleasure(87), do: 24
  defp pain_or_pleasure(93), do: 73
  defp pain_or_pleasure(95), do: 75
  defp pain_or_pleasure(99), do: 78
  defp pain_or_pleasure(pos), do: pos
end
