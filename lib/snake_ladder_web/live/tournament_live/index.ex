defmodule SnakeLadderWeb.TournamentLive.Index do
  use SnakeLadderWeb, :live_view

  alias SnakeLadderWeb.Presence

  @impl true
  def mount(%{"t" => topic} = params, _assigns, socket) do
    player = if Map.get(params, "foreman") == "true", do: "player1", else: "player2"

    if connected?(socket) do
      SnakeLadderWeb.Endpoint.subscribe(topic)
      Presence.track(self(), topic, player, %{})
    end

    {:ok,
     socket
     |> assign(
       players: %{
         "player1" => %{name: "Player 1", position: 1},
         "player2" => %{name: "Player 2", position: 1}
       },
       dice: "",
       current_player: player,
       topic: topic,
       current_turn: "player1",
       game_started: false
     )}
  end

  def mount(_params, _assigns, socket) do
    token = :crypto.strong_rand_bytes(5) |> Base.url_encode64() |> binary_part(0, 5)

    {:ok,
     push_redirect(socket,
       to: Routes.tournament_index_path(socket, :index, t: token, foreman: true)
     )}
  end

  @impl true
  def handle_info(%{event: "presence_diff"}, socket) do
    user_count = Presence.list(socket.assigns.topic) |> map_size()

    if user_count == 2 do
      {:noreply, socket |> assign(game_started: true)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{event: "roll", payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end
end
