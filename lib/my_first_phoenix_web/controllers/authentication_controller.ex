defmodule MyFirstPhoenixWeb.AuthenticationController do
  use MyFirstPhoenixWeb, :controller

  alias MyFirstPhoenix.Tictactoe.AuthenticationContext
  alias MyFirstPhoenix.Tictactoe.Player

  def sign_in(conn, _params) do
    changeset = AuthenticationContext.player_changeset(%Player{})
    render(conn, :sign_in, changeset: changeset)
  end

  def do_sign_in(conn, %{"player" => player_params}) do
    case AuthenticationContext.sign_in(player_params) do
      {:ok, player} ->
        conn
        |> put_session(:current_user, player)
        |> put_flash(:info, "Signed in")
        |> redirect(to: ~p"/tictactoe")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :sign_in, changeset: changeset)
    end


    # result = %Player{}
    #   |> Player.changeset(player_params)
    #   |> Player.validate()

    # #IO.inspect(result)
    # case result.valid? do
    #   true ->
    #     conn
    #     |> put_session(:current_user, player_params["name"])
    #     |> put_flash(:info, "Signed in")
    #     |> redirect(to: ~p"/tictactoe")

    #   _ ->
    #     render(conn, :sign_in, changeset: result)
    # end
  end

  def sign_out(conn, _params) do
    redirect(conn, to: ~p"/tictactoe")
  end
end
