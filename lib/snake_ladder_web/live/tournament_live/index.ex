defmodule SnakeLadderWeb.TournamentLive.Index do
  use SnakeLadderWeb, :live_view

  alias SnakeLadderWeb.Presence
  @impl true
  def mount(%{"t" => token} = params, _assigns, socket) do
    presence_id = if Map.get(params, "foreman") == "true", do: "player1", else: "player2"

    if connected?(socket) do
      SnakeLadderWeb.Endpoint.subscribe(token)
      Presence.track(self(), token, presence_id, %{})
    end

    {:ok,
     socket
     |> assign(
       players: %{
         player1: %{name: "Player 1", position: 1, won: false, turn: false},
         player2: %{name: "Player 2", position: 1, won: false, turn: false}
       },
       dice: "",
       current_turn: "player1",
       current_player: presence_id,
       token: token,
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
    user_count = Presence.list(socket.assigns.token) |> map_size()

    if user_count == 2 do
      # players = Map.update(socket.assigns.players, :player1, false, &%{&1 | turn: true})
      {:noreply, socket |> assign(game_started: true)}
    else
      {:noreply, socket}
    end
  end

  def handle_info(%{event: "abcs", payload: state}, socket) do
    {:noreply,
     assign(socket, players: state.players, dice: state.dice, current_turn: state.current_turn)}
  end
end
