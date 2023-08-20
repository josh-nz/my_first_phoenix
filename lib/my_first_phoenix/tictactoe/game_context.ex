defmodule MyFirstPhoenix.Tictactoe.GameContext do
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

      # TODO: Add game to registry.
  end
end
