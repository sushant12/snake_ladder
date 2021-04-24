defmodule SnakeLadderWeb.TournamentLive.Index do
  use SnakeLadderWeb, :live_view

  alias SnakeLadderWeb.Presence

  @impl true
  def mount(%{"t" => token, "foreman" => "true"}, _assigns, socket) do
    if connected?(socket) do
      SnakeLadderWeb.Endpoint.subscribe(token)
      Presence.track(self(), token, "player1", %{})
    end

    {:ok, socket |> assign(token: token, game_started: false)}
  end

  def mount(%{"t" => token}, _assigns, socket) do
    if connected?(socket) do
      SnakeLadderWeb.Endpoint.subscribe(token)
      Presence.track(self(), token, "player2", %{})
    end

    {:ok, socket |> assign(token: token, game_started: false)}
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
    presence = Presence.list(socket.assigns.token)
    user_count = presence |> map_size()
    players = presence |> Map.keys()

    if user_count == 2 do
      {:noreply, socket |> assign(game_started: true, players: players)}
    else
      {:noreply, socket |> assign(players: players)}
    end
  end
end
