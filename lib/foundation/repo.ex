defmodule Foundation.Repo do
  use Ecto.Repo,
    otp_app: :foundation,
    adapter: Ecto.Adapters.Postgres
end
