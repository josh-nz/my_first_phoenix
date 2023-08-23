defmodule MyFirstPhoenix.Tictactoe.GameSupervisor do
  use DynamicSupervisor
  alias MyFirstPhoenix.Tictactoe.GameSupervisor.Storage


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

  def create_game({:error, _} = error), do: error
  def create_game({:ok, game}) do
    # Here, id is not a keyword list, but a string. It
    # will still be passed to the start_link(opts), but
    # opts will only be the string this time.
    # Refer also to the comments in MyFirstPhoenix.Tictactoe.GameServer.

    # This should be the GameServer docs, but unsure where it acutally goes.
    # It was in the incorrect place, so is here for right now.
    # https://hexdocs.pm/elixir/Supervisor.html#start_link/2
    # Second tuple element is passed to module.child_spec(arg),
    # which will find it's way to start_link(opts).

    game_id = Storage.next_game_id()
    child =
      DynamicSupervisor.start_child(
        __MODULE__,
        {MyFirstPhoenix.Tictactoe.GameServer, Map.put(game, :game_id, game_id)})

    case child do
      {:ok, _pid} -> {:ok, game_id}
      error -> error
    end
  end


  @impl true
  def init(_init_arg) do
    Storage.start_link([])
    # :one_for_one strategy: if a child process crashes, only that process is restarted.
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
