defmodule SnakeLadderWeb.Game do
  use SnakeLadderWeb, :live_component
  alias SnakeLadder.GameServer
  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(Map.put(assigns, :board, SnakeLadder.Board.new()))}
  end

  @impl true
  def handle_event("roll", _value, socket) do
    GameServer.dice_rolled(socket.assigns.game.token)
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="game row">
      <div class="board-wrapper column column-60">
        <div id="overlay"></div>
        <table id='board' border="1px">
          <%= for row <- @board do %>
            <tr>
              <%= for col <- row do %>
                <td class="slot <%= if rem(col,2) == 0, do: 'slot-yellow', else: 'slot-white' %>">
                  <%= col %>
                  <%= for player <- @game.players do %>
                    <%= if player.position == col do %>
                      <%= if player.name == "player1" do %>
                        <div class="player1 lupid"></div>
                      <% else %>
                        <div class="player2 pig"></div>
                      <% end %>
                    <% end %>
                  <% end %>
                </td>
              <% end %>
            </tr>
          <% end %>
        </table>
      </div>

      <div class="sidebar column column-25">
        <div class="row">
          <div class="column players">
            <div class="row">
              <%= for player <- @game.players do %>
                <div class="player column column-50">
                  <div class="<%= player.name %>-img">
                    <%= if player.name == @game.current_call.name do %>
                      <%= img_tag(Routes.static_path(@socket, "/images/circle.png"), class: "circle") %>
                    <% end %>
                  </div>
                  <div class="player-name"><%= player.name %></div>
                </div>
              <% end %>
            </div>
          </div>
        </div>
        <div class="row">
          <div class="column dice-wrapper">
            <div class="row">
              <div class="dice-result">
                <%= @game.dice_state %>
              </div>
            </div>
            <div class="row">
              <div class="dice">
                <%= if @player.name == @game.current_call.name do %>
                  <button phx-click='roll' phx-target="<%= @myself%>">Roll</button>
                <% end %>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
