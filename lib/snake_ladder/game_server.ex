defmodule SnakeLadder.GameServer do
  use GenServer

  alias SnakeLadder.Game
  alias SnakeLadder.Player
  require Logger

  @spec dice_rolled(String.t()) :: :ok
  def dice_rolled(game_token) do
    case game_pid(game_token) do
      game_pid when is_pid(game_pid) ->
        game = GenServer.call(game_pid, :dice_rolled)
        SnakeLadderWeb.Endpoint.broadcast!(game_token, "dice_rolled", game)
      nil ->
        {:error, :game_not_found}
    end
  end

  @spec add_player(String.t(), Player.t()) :: :ok | {:error, :game_not_found}
  def add_player(game_token, player) do
    case game_pid(game_token) do
      game_pid when is_pid(game_pid) ->
        {:ok, players} = GenServer.call(game_pid, {:add_player, player})
        SnakeLadderWeb.Endpoint.broadcast!(game_token, "player_added", players)
      nil ->
        {:error, :game_not_found}
    end
  end

  @spec add_current_call(String.t(), Player.t()) :: :ok | {:error, :game_not_found}
  def add_current_call(game_token, player) do
    case game_pid(game_token) do
      game_pid when is_pid(game_pid) ->
        if player.name == "player1", do: GenServer.call(game_pid, {:add_current_call, player})
      nil ->
        {:error, :game_not_found}
    end
  end

  @spec get_game(String.t()) :: {:ok, Game.t()} | {:error, :game_not_found}
  def get_game(game_token) do
    case game_pid(game_token) do
      game_pid when is_pid(game_pid) ->
        GenServer.call(game_pid, :get_game)
      _ ->
        {:error, :game_not_found}
    end
  end

  def game_pid(game_token) do
    game_token
    |> via_tuple()
    |> GenServer.whereis()
  end
  def start_link(token) do
    GenServer.start_link(__MODULE__, token, name: via_tuple(token))
  end

  @impl true
  def init(token) do
    Logger.info("Creating game server for #{token})")

    {:ok, %{game: Game.new(token)}}
  end

  @impl true
  def handle_call({:add_player, player}, _from, state) do
    {:ok, game} =  Game.add_player(state.game, player)
    {:reply, {:ok, game.players}, %{state | game: game}}
  end

  def handle_call({:add_current_call, player}, _from, state) do
    {:ok, game} =  Game.add_current_call(state.game, player)
    {:reply, state, %{state | game: game}}
  end

  def handle_call(:dice_rolled, _from, state) do
    {:ok, game} = Game.roll_dice(state.game)
    {:reply, game, %{state | game: game}}
  end

  def handle_call(:get_game, _from, state) do
    {:reply, {:ok, state.game}, state}
  end

  defp via_tuple(token) do
    {:via, Registry, {SnakeLadder.GameRegistry, token}}
  end
end
