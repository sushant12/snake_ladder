defmodule SnakeLadderWeb.Game do
  use Phoenix.LiveComponent
  alias SnakeLadderWeb.Presence

  @impl true
  def update(assigns, socket) do
    board_matrix =
      100..1
      |> Enum.chunk_every(10)
      |> Enum.with_index()
      |> Enum.map(fn {x, i} ->
        if rem(i, 2) != 0 do
          Enum.reverse(x)
        else
          x
        end
      end)

    {:ok, socket |> assign(players: assigns.players, board_matrix: board_matrix)}
  end
end
