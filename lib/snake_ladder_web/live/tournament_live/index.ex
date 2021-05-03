defmodule SnakeLadderWeb.TournamentLive.Index do
  use SnakeLadderWeb, :live_view

  # alias SnakeLadderWeb.Presence
  alias SnakeLadder.Player
  alias SnakeLadder.GameServer

  @impl true
  def mount(%{"t" => token} = params, _assigns, socket) do
    player = if Map.get(params, "foreman") == "true", do: "player1", else: "player2"
    plyr = Player.new(player)
    {:ok, game} = GameServer.get_game(token)

    GameServer.add_player(token, plyr)
    if connected?(socket) do
      SnakeLadderWeb.Endpoint.subscribe(token)
      # Presence.track(self(), token, player, %{})
    end

    {:ok,
     socket |> assign(game: game, player: plyr)}
  end

  def mount(_params, _assigns, socket) do
    token = SnakeLadder.Utils.random_short_id()
    SnakeLadder.GameSupervisor.start_game(token)
    {:ok,
     push_redirect(socket,
       to: Routes.tournament_index_path(socket, :index, t: token, foreman: true)
     )}
  end

  @impl true
  def handle_info(%{event: "roll", payload: state}, socket) do
    {:noreply, assign(socket, state)}
  end

  def handle_info(%{event: "player_added", payload: players}, socket) do
    {:noreply,  assign(socket, game: %{socket.assigns.game | players: players})}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="tournament">
      <%= if length(@game.players) == 2 do %>
        <%= live_component(@socket, SnakeLadderWeb.Game,
          id: :game,
          game: @game,
          player: @player
          ) %>
      <% else %>
        <div class="row">
          <div class="notice column column-30">
            <%= if length(@game.players) == 1 do %>
              <p>Copy and share the url </p>
              <p>with your friend </p>
            <% else %>
              <p>Preparing the Game... </p>
            <% end %>
            <input type="text" value="<%= SnakeLadderWeb.Endpoint.url() %>/?t=<%= @game.token %>">
          </div>
        </div>
      <% end %>
    </div>
    """
  end

end
