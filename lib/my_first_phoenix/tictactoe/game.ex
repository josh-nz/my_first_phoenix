defmodule MyFirstPhoenix.Tictactoe.Game do
  import Ecto.Changeset

  defstruct [:game_id, :title, :description, :player_x, :player_o]

  def changeset(game, attrs \\ %{}) do
    types = %{title: :string, description: :string, player_x: :string, player_o: :string}
    {game, types} |> cast(attrs, Map.keys(types))
  end

  def validate(changeset) do
    changeset
    |> validate_required([:title])
    |> validate_length(:title, max: 50)
    |> validate_length(:description, max: 200)
    # Emulate a repo action, returns appropriate {:ok, ...} or {:error, ...} tuple.
    |> apply_action(:insert)
  end
end
