defmodule MyFirstPhoenix.Tictactoe.Game do
  import Ecto.Changeset

  def changeset(game, attrs \\ %{}) do
    types = %{title: :string, description: :string}
    {game, types} |> cast(attrs, Map.keys(types))
  end

  def validate(changeset) do
    validate_required(changeset, [:title])
  end
end
