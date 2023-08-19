defmodule MyFirstPhoenix.Tictactoe.Game do
  use Agent, restart: :temporary

  def start_link(options \\ []) do
    Agent.start_link(fn -> %{} end, options)
  end
end
