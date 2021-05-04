defmodule SnakeLadderWeb.TournamentLive.Index do
  use SnakeLadderWeb, :live_view

  alias SnakeLadder.Player
  alias SnakeLadder.GameServer

  @impl true
  def mount(%{"t" => token} = params, _assigns, socket) do
    player_name = if Map.get(params, "foreman") == "true", do: "player1", else: "player2"
    player = Player.new(player_name)
    GameServer.add_player(token, player)

    {:ok, game} = GameServer.get_game(token)
    if player.name == "player1", do: GameServer.add_current_call(game.token, player)

    if connected?(socket) do
      SnakeLadderWeb.Endpoint.subscribe(token)
    end

    {:ok, socket |> assign(game: game, player: player)}
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
  def handle_info(%{event: "player_added", payload: players}, socket) do
    game = socket.assigns.game
    {:noreply, assign(socket, game: %{game | players: players})}
  end

  def handle_info(%{event: "dice_rolled", payload: game}, socket) do
    {:noreply, assign(socket, game: game)}
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
