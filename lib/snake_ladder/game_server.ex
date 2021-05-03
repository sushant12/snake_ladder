defmodule SnakeLadder.GameServer do
  use GenServer

  alias SnakeLadder.Game
  alias SnakeLadder.Player
  require Logger

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


  @spec get_game(String.t()) :: {:ok, Game.t()} | {:error, :game_not_found}
  def get_game(game_token) do
    case game_pid(game_token) do
      game_pid when is_pid(game_pid) ->
        GenServer.call(game_pid, :get_game)
      _ ->
        {:error, :game_not_found}
    end
  end

  defp game_pid(game_token) do
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
    case Game.add_player(state.game, player) do
      {:ok, game} ->
        {:reply, {:ok, game.players}, %{state | game: game}}
    end
  end

  def handle_call(:get_game, _from, state) do
    {:reply, {:ok, state.game}, state}
  end

  defp via_tuple(token) do
    {:via, Registry, {SnakeLadder.GameRegistry, token}}
  end
end
