defmodule SnakeLadderWeb.Game do
  use SnakeLadderWeb, :live_component

  # alias SnakeLadderWeb.Presence

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

    {:ok,
     socket
     |> assign(
       token: assigns.token,
       players: assigns.players,
       board_matrix: board_matrix,
       dice: assigns.dice,
       current_player: assigns.current_player,
       current_turn: assigns.current_turn
     )}
  end

  @impl true
  def handle_event("roll", _value, socket) do
    current_player = socket.assigns.current_player

    current_turn =
      if socket.assigns.current_turn == "player1" do
        "player2"
      else
        "player1"
      end

    dice = Enum.random(1..6)

    players =
      Map.update(
        socket.assigns.players,
        :"#{current_player}",
        1,
        &%{&1 | position: sus(&1.position + dice)}
      )

    SnakeLadderWeb.Endpoint.broadcast!(socket.assigns.token, "abcs", %{
      players: players,
      dice: dice,
      current_turn: current_turn
    })

    {:noreply, socket}
  end

  # @impl true
  # def handle_info(%{event: "abc"}, socket) do
  #   {:noreply, push_event(socket, "video_played", %{})}
  # end

  defp sus(2), do: 8
  defp sus(4), do: 14
  defp sus(9), do: 31
  defp sus(13), do: 27
  defp sus(20), do: 38
  defp sus(29), do: 11
  defp sus(40), do: 59
  defp sus(51), do: 67
  defp sus(54), do: 34
  defp sus(62), do: 12
  defp sus(63), do: 81
  defp sus(64), do: 43
  defp sus(71), do: 91
  defp sus(93), do: 73
  defp sus(95), do: 75
  defp sus(99), do: 78
  defp sus(num), do: num
end
