defmodule MyFirstPhoenix.Tictactoe.GameSupervisor.Storage do
  use Agent

  def start_link(_args) do
    Agent.start_link(fn -> 1 end, name: __MODULE__)
  end

  def next_game_id() do
    id = Agent.get_and_update(__MODULE__, &({&1, &1+1}))
    IO.inspect(id, label: "game id ")
    id
  end
end
