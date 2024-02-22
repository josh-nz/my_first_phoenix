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

  def compare(game1, game2) do
    cond do
      game1.game_id > game2.game_id -> :gt
      game1.game_id < game2.game_id -> :lt
      true -> :eq
    end
  end
end

# defmodule Game do
#   use Ecto.Schema

#   embedded_schema do
#     field :title, :string
#     field :description, :string
#     embeds_one :player_x, Player
#     embeds_one :player_o, Player
#   end

#   def changeset(game, attrs \\ %{}) do
#     game
#     |> cast(attrs, [:title, :description])
#     |> cast_embed(:player_x) # uses Player.changeset/2 by default
#     |> cast_embed(:player_o)
#   end
# end
