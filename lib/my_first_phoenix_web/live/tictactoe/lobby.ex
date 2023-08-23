defmodule MyFirstPhoenixWeb.Tictactoe.Lobby do
  use MyFirstPhoenixWeb, :live_view
  alias MyFirstPhoenix.Tictactoe.GameContext

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      GameContext.subscribe("lobby")
    end

    games = GameContext.list_games()
    changeset = GameContext.game_changeset(%{})

    {:ok, assign(socket,
      games: games,
      show: false,
      form: to_form(changeset, as: :game))
    }
  end

  @impl true
  def handle_event("validate_create_game", %{"game" => form_params}, socket) do

    changeset = %{}
      |> GameContext.game_changeset(form_params)
      |> GameContext.validate_game
      |> Map.put(:action, :validate)

    # IO.inspect(changeset, label: "changeset")

    {:noreply, assign(socket, form: to_form(changeset, as: :game))}
  end

  @impl true
  def handle_event("create_game", %{"game" => form_params}, socket) do
    case GameContext.create_game(form_params) do
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

    <div :if={length(@games) == 0}>No games yet, why not start one?</div>
    <div><.link phx-click={show_modal("create_game_modal")}>Create new game</.link></div>

    <.modal id="create_game_modal" show={@show}>
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
      <li><.link navigate={~p"/tictactoe/#{g}"}><%= g %></.link></li>
    </ul>
    """
  end

end
