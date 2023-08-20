defmodule MyFirstPhoenix.Tictactoe.GameContext do
  alias Phoenix.PubSub

  alias MyFirstPhoenix.Tictactoe.GameSupervisor
  alias MyFirstPhoenix.Tictactoe.Game

  def list_games() do
    GameSupervisor.list_games()
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
      |> broadcast(:new_game)

      # TODO: Add game to registry.

  end

  def subscribe(room) do
    PubSub.subscribe(MyFirstPhoenix.PubSub, "tictactoe:#{room}")
  end

  defp broadcast({:error, _} = error, _event), do: error
  defp broadcast({:ok, game} = ok, event) do
    PubSub.broadcast(MyFirstPhoenix.PubSub, "tictactoe:lobby", {event, game})
    ok
  end
end
