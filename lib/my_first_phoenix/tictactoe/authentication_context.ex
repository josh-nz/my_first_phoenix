defmodule MyFirstPhoenix.Tictactoe.AuthenticationContext do
  alias MyFirstPhoenix.Tictactoe.Player

  def player_changeset(player, params \\ %{}) do
    Player.changeset(player, params)
  end

  def sign_in(params) do
    %Player{}
    |> Player.changeset(params)
    |> Player.validate()
  end
end
