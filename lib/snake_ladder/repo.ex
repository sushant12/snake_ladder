defmodule SnakeLadder.Repo do
  use Ecto.Repo,
    otp_app: :snake_ladder,
    adapter: Ecto.Adapters.Postgres
end
