defmodule MyFirstPhoenixWeb.PageController do
  use MyFirstPhoenixWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    IO.inspect(get_session(conn), label: "session ")
    IO.inspect(conn, label: "conn ")
    render(conn, :home, layout: false)
  end

  def chat(conn, _params) do
    render(conn, :chat)
  end

  def session(conn, _params) do
    conn = put_session(conn, :test, "hello")
    conn = put_session(conn, :test2, "hello2")
    redirect(conn, to: ~p"/")
  end
end
