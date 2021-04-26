defmodule SnakeLadderWeb.Game do
  use SnakeLadderWeb, :live_component

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
     |> assign(Map.put(assigns, :board_matrix, board_matrix))}
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
        current_player,
        1,
        &%{&1 | position: pain_or_pleasure(&1.position + dice)}
      )

    SnakeLadderWeb.Endpoint.broadcast!(socket.assigns.topic, "roll", %{
      players: players,
      dice: dice,
      current_turn: current_turn
    })

    {:noreply, socket}
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
  defp pain_or_pleasure(62), do: 21
  defp pain_or_pleasure(63), do: 81
  defp pain_or_pleasure(64), do: 43
  defp pain_or_pleasure(71), do: 91
  defp pain_or_pleasure(93), do: 73
  defp pain_or_pleasure(95), do: 75
  defp pain_or_pleasure(99), do: 78
  defp pain_or_pleasure(num), do: num
end
