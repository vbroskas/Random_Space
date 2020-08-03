defmodule Space.Repo do
  use Ecto.Repo,
    otp_app: :space,
    adapter: Ecto.Adapters.Postgres
end
