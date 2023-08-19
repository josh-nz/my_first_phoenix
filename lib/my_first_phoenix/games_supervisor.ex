defmodule MyFirstPhoenix.RootGamesSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      {DynamicSupervisor, name: MyFirstPhoenix.GamesSupervisor},
      {Registry, keys: :unique, name: MyFirstPhoenix.GamesRegistry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
