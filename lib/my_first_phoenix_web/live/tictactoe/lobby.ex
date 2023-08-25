defmodule MyFirstPhoenixWeb.Tictactoe.Lobby do
  use MyFirstPhoenixWeb, :live_view

  alias MyFirstPhoenix.Tictactoe.Game
  alias MyFirstPhoenix.Tictactoe.GameContext

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket) do
      GameContext.subscribe("lobby")
    end

    games = GameContext.list_games()
    changeset = GameContext.game_changeset(%Game{})

    {:ok, assign(socket,
      current_user: session["current_user"],
      games: games,
      form: to_form(changeset, as: :game))
    }
  end

  @impl true
  def handle_event("validate_create_game", %{"game" => form_params}, socket) do

    changeset = %Game{}
      |> GameContext.game_changeset(form_params)
      |> GameContext.validate_game
      |> Map.put(:action, :validate)

    # IO.inspect(changeset, label: "changeset")

    {:noreply, assign(socket, form: to_form(changeset, as: :game))}
  end

  @impl true
  def handle_event("create_game", %{"game" => form_params}, socket) do
    case GameContext.create_game(socket.assigns.current_user, form_params) do
      {:ok, changes} ->
        # IO.puts("OK clause")
        {:noreply,
         socket
         #|> hide_modal("create_game_modal")
         # https://hexdocs.pm/phoenix_live_view/js-interop.html#handling-server-pushed-events
         |> put_flash(:info, "Game created")
        #  |> assign(show: false)
        #  |> update(:games, &([changes.title | &1]))
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        # IO.inspect(changeset)
        {:noreply, assign(socket, form: to_form(changeset, as: :game))}
    end
  end

  @impl true
  def handle_info({:new_game, game}, socket) do
    {:noreply, update(socket, :games, &([game | &1]))}
  end


  @impl true
  def render(assigns) do
    ~H"""
    <.header>Welcome to the Tic Tac Toe lobby</.header>

    <div :if={@current_user}>
      <h2>
        Welcome, <%= @current_user.name %>
        <.link href={~p"/sign_out"}>Sign out</.link>
      </h2>
      <div><.link phx-click={show_modal("create_game_modal")}>Create new game</.link></div>
    </div>

    <div :if={@current_user == nil}>
      <h2><.link href={~p"/sign_in"}>Sign in</.link></h2>
      <div>Sign in to create or join a game</div>
    </div>

    <div :if={length(@games) == 0}>No games yet, why not start one?</div>

    <.modal id="create_game_modal">
      <.header>Create new game</.header>
      <%!-- https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#form/1-examples-inside-liveview --%>
      <.simple_form for={@form} phx-change="validate_create_game" phx-submit="create_game">
        <.input field={@form[:title]} label="Title"/>
        <.input field={@form[:description]} label="Description" />
        <:actions>
          <.button type="submit">Create</.button>
          <.link phx-click={JS.exec("data-cancel", to: "#create_game_modal")}>Cancel</.link>
        </:actions>
      </.simple_form>
    </.modal>

    <ul :for={g <- @games}>
      <li><.link navigate={~p"/tictactoe/#{g.game_id}"}><%= g.title %></.link></li>
    </ul>
    """
  end

end
