defmodule MyFirstPhoenix.Tictactoe.RootSupervisor do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      MyFirstPhoenix.Tictactoe.GameSupervisor,

      # https://hexdocs.pm/elixir/Supervisor.html#start_link/2
      # Second tuple element is passed to module.child_spec(arg),
      # which will find it's way to start_link(opts).
      {Registry, keys: :unique, name: MyFirstPhoenix.Tictactoe.GameRegistry}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
