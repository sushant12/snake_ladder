defmodule SnakeLadderWeb.Presence do
  use Phoenix.Presence, otp_app: :snake_ladder, pubsub_server: SnakeLadder.PubSub
end
