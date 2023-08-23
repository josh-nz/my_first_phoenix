defmodule MyFirstPhoenix.Tictactoe.RootSupervisor do
  use Supervisor

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Registry, keys: :unique, name: MyFirstPhoenix.Tictactoe.GameRegistry},
      MyFirstPhoenix.Tictactoe.GameSupervisor
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
