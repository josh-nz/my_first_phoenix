defmodule MyFirstPhoenixWeb.Tictactoe.Lobby do
  use MyFirstPhoenixWeb, :live_view

  alias MyFirstPhoenix.Tictactoe.GameSupervisor

  @impl true
  def mount(_params, _session, socket) do
    games = GameSupervisor.list_games()
    {:ok, assign(socket, games: games)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    Welcome to the Tic Tac Toe lobby.

    <div :if={length(@games) == 0}>No games yet, why not start one?</div>

    <ul :for={g <- @games}>
      <li><%= g %></li>
    </ul>
    """
  end

end
