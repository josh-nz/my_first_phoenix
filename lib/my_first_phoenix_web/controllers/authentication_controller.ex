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
        |> renew_session()
        |> put_session(:current_user, player)
        |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(player.name)}")
        |> put_flash(:info, "Signed in")
        |> redirect(to: ~p"/tictactoe")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :sign_in, changeset: changeset)
    end
  end

  def sign_out(conn, _params) do
    if live_socket_id = get_session(conn, :live_socket_id) do
      MyFirstPhoenixWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
    end

    conn
    |> renew_session()
    |> put_flash(:info, "Signed out")
    |> redirect(to: ~p"/tictactoe")
  end

  # Taken from phx.gen.auth
  # user_auth.ex, renew_session/1
  defp renew_session(conn) do
    conn
      |> configure_session(renew: true)
      |> clear_session()
  end
end
