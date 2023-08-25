defmodule MyFirstPhoenix.Tictactoe.Player do
  import Ecto.Changeset

  defstruct [:name]

  def changeset(player, attrs \\ %{}) do
    types = %{name: :string}
    {player, types} |> cast(attrs, Map.keys(types))
  end

  def validate(changeset) do
    changeset
      |> validate_required([:name])
      |> validate_length(:name, max: 50)
      |> apply_action(:insert)
  end
end
