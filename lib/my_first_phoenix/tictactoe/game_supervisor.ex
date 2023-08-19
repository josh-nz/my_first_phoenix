defmodule MyFirstPhoenix.Tictactoe.GameSupervisor do
  use DynamicSupervisor
  alias MyFirstPhoenix.Tictactoe.Game

  def start_link(_opts) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def create_game(game_name) do
    # Here, game_name is not a keyword list, but a string. It
    # will still be passed to the start_link(opts), but
    # opts will only be the string this time.
    # Refer also to the comments in MyFirstPhoenix.Tictactoe.Server.
    DynamicSupervisor.start_child(__MODULE__, {Game, game_name})
  end

  @impl true
  def init(_init_arg) do
    # :one_for_one strategy: if a child process crashes, only that process is restarted.
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
