defmodule MyFirstPhoenix.Repo do
  use Ecto.Repo,
    otp_app: :my_first_phoenix,
    adapter: Ecto.Adapters.Postgres
end
