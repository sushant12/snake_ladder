defmodule SnakeLadder.GameSupervisor do
  @moduledoc """
  Dynamically starts a game server
  """

  use DynamicSupervisor

  alias __MODULE__
  alias SnakeLadder.GameServer

  def start_link(_arg) do
    DynamicSupervisor.start_link(GameSupervisor, nil, name: GameSupervisor)
  end

  @impl true
  def init(nil) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_game(token) do
    child_spec = %{
      id: GameServer,
      start: {GameServer, :start_link, [token]},
      restart: :transient
    }

    DynamicSupervisor.start_child(GameSupervisor, child_spec)
  end
end
