defmodule MyFirstPhoenix.Tictactoe.GameSupervisor do
  use DynamicSupervisor

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def list_games() do
    Registry.select(MyFirstPhoenix.Tictactoe.GameRegistry,
    #   [{{:"$1", :"$2", :"$3"},
    #     [],
    #     [{{:"$1", :"$2", :"$3"}}]
    #   }]
    # )
    [{{:"$1", :_, :_}, [], [:"$1"]}])
  end

  def create_game(id) do
    # Here, id is not a keyword list, but a string. It
    # will still be passed to the start_link(opts), but
    # opts will only be the string this time.
    # Refer also to the comments in MyFirstPhoenix.Tictactoe.Server.
    DynamicSupervisor.start_child(__MODULE__, {MyFirstPhoenix.Tictactoe.GameServer, id})


  end


  @impl true
  def init(_init_arg) do
    # :one_for_one strategy: if a child process crashes, only that process is restarted.
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
