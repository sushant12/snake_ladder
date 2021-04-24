defmodule SnakeLadderWeb.RoomChannel do
  use SnakeLadderWeb, :channel

  def join("room:" <> token, _params, socket) do
    IO.inspect("=====")
    IO.inspect(token)
    IO.inspect("=====")
    {:ok, socket}
  end
end
