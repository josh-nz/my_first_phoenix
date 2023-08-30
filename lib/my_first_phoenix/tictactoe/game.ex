defmodule MyFirstPhoenix.Tictactoe.Game do
  import Ecto.Changeset

  alias MyFirstPhoenix.Tictactoe.Player

  defstruct [:game_id, :title, :description, :player_x, :player_o]

  def changeset(game, attrs \\ %{}) do
    types = %{title: :string, description: :string, player_x: Player, player_o: Player}
    {game, types}
    |> cast(attrs, [:title, :description])  # Fails, struct Player.cast/1 is undefined or private
    # |> cast_assoc(:player_x)  # Fails, expected `player_x` to be an assoc got struct
    # |> cast_assoc(:player_o)
    |> validate()
  end

  def validate(changeset) do
    changeset
    |> validate_required([:title])
    |> validate_length(:title, max: 50)
    |> validate_length(:description, max: 200)
  end
end
