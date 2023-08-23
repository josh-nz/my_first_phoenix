defmodule MyFirstPhoenix.Tictactoe.GameContext do
  alias Phoenix.PubSub

  alias MyFirstPhoenix.Tictactoe.GameSupervisor
  alias MyFirstPhoenix.Tictactoe.GameServer
  alias MyFirstPhoenix.Tictactoe.Game

  def list_games() do
    GameSupervisor.list_games()
      # |> Enum.map(game_metadata)
  end

  def game_metadata(game_id) do
    GameServer.game_metadata(game_id)
  end

  def game_changeset(game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end

  def validate_game(changeset) do
    Game.validate(changeset)
  end

  def create_game(attrs) do
    game_changeset(%{}, attrs)
      |> validate_game
      # Emulate a repo action, returns appropriate {:ok, ...} or {:error, ...} tuple.
      |> Ecto.Changeset.apply_action(:insert)
      |> GameSupervisor.create_game()
      |> broadcast(:new_game)
  end

  def subscribe(topic) do
    PubSub.subscribe(MyFirstPhoenix.PubSub, "tictactoe:#{topic}")
  end

  defp broadcast({:error, _} = error, _event), do: error
  defp broadcast({:ok, game} = ok, event) do
    PubSub.broadcast(MyFirstPhoenix.PubSub, "tictactoe:lobby", {event, game})
    ok
  end
end
