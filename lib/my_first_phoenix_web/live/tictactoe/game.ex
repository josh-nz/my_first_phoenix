defmodule MyFirstPhoenixWeb.Tictactoe.Game do
  use MyFirstPhoenixWeb, :live_view

  alias MyFirstPhoenix.Tictactoe.Game
  alias MyFirstPhoenix.Tictactoe.GameContext

  @impl true
  def mount(%{"game_id" => game_id_str} = _params, session, socket) do
    game_id = String.to_integer(game_id_str)

    if connected?(socket) do
      GameContext.subscribe(game_id)
    end

    case GameContext.load_game(game_id) do
      {:ok, %{metadata: %Game{} = meta, turns: turns}} ->
        current_user = session["current_user"]
        {:ok, assign(socket, %{
          current_user: current_user,
          your_turn?: your_turn?(current_user, meta, hd(turns)),
          meta: meta,
          current_turn: hd(turns),
          game_turns: turns
        })}
      {:error, _} ->
        {:ok, push_navigate(socket, to: ~p"/tictactoe/")}
    end
  end

  @impl true
  def handle_event("square-clicked", %{"grid-id" => grid_id_str}, socket) do
    grid_id = String.to_integer(grid_id_str)

    turn = GameContext.take_turn(self(), socket.assigns.meta.game_id, grid_id)

    {:noreply, assign(socket, %{
      your_turn?: your_turn?(socket.assigns.current_user, socket.assigns.meta, turn),
      current_turn: turn,
      game_turns: [turn | socket.assigns.game_turns]
    })}
  end

  @impl true
  def handle_event("undo", %{"to-turn" => to_turn_str}, socket) do
    to_turn = String.to_integer(to_turn_str)

    turns = GameContext.rewind(self(), socket.assigns.meta.game_id, to_turn)

    {:noreply, assign(socket, %{
      your_turn?: your_turn?(socket.assigns.current_user, socket.assigns.meta, hd(turns)),
      current_turn: hd(turns),
      game_turns: turns
    })}
  end


  # Broadcasts

  @impl true
  def handle_info({:turn_taken, turn}, socket) do
    your_turn? = your_turn?(socket.assigns.current_user, socket.assigns.meta, turn)
    IO.inspect(your_turn?, label: "turn")
    {:noreply, assign(socket,
      your_turn?: your_turn?,
      current_turn: turn,
      game_turns: [turn | socket.assigns.game_turns])}
  end

  @impl true
  def handle_info({:game_history_changed, turns}, socket) do
    {:noreply, assign(socket,
      your_turn?: your_turn?(socket.assigns.current_user, socket.assigns.meta, hd(turns)),
      current_turn: hd(turns),
      game_turns: turns)}
  end

  @impl true
  def handle_info({:player_added, %Game{} = game}, socket) do
    {:noreply, assign(socket,
      meta: game,
      your_turn?: your_turn?(
        socket.assigns.current_user,
        socket.assigns.meta,
        socket.assigns.current_turn))}
  end


  defp your_turn?(current_user, meta, current_turn) do
    cond do
      is_nil(current_user) -> false
      meta.player_x
        && meta.player_x.name == current_user.name
        && current_turn.next_player == "X" -> true
      meta.player_o
        && meta.player_o.name == current_user.name
        && current_turn.next_player == "O" -> true
      true -> false
    end
  end


  @impl true
  def render(assigns) do
    ~H"""
    <.back navigate={~p"/tictactoe"}>Return to lobby</.back>
    <.header>Playing game <%= @meta.title %></.header>

    <dl>
      <dt>Player X: </dt>
      <dd><%= @meta.player_x && @meta.player_x.name %></dd>
      <dt>Player O: </dt>
      <dd><%= @meta.player_o && @meta.player_o.name %></dd>
    </dl>

    <.game_status game_status={@current_turn.status} player={@current_turn.next_player}  />

    <.board_row indexes={[1,2,3]} board={@current_turn.board} your_turn?={@your_turn?} />
    <.board_row indexes={[4,5,6]} board={@current_turn.board} your_turn?={@your_turn?} />
    <.board_row indexes={[7,8,9]} board={@current_turn.board} your_turn?={@your_turn?} />

    <.game_history history={@game_turns} />
    """
  end


  attr :game_status, :atom, required: true
  attr :player, :string, required: true
  def game_status(%{game_status: :undecided} = assigns) do
    ~H"""
    <div>Current player: <%= @player %></div>
    """
  end

  def game_status(assigns) do
    ~H"""
    <div>
      <p :if={@game_status == :winner}>Game over. Winner was player <%= @player %>.</p>
      <p :if={@game_status == :stalemate}>Game over, stalemate.</p>
      <.button phx-click="undo" phx-value-to-turn="0">New game</.button>
    </div>
    """
  end


  attr :indexes, :list, required: true
  attr :board, :map, required: true
  attr :your_turn?, :boolean, required: true
  def board_row(assigns) do
    ~H"""
    <div class="flex flex-row">
      <.square :for={n <- @indexes} id={n} state={@board[n]} your_turn?={@your_turn?} />
    </div>
    """
  end


  attr :id, :string, required: true
  attr :state, :string, required: true
  attr :your_turn?, :boolean, required: true
  def square(assigns) do
    ~H"""
    <button
      class="border border-black text-2xl font-bold text-center h-8 w-8 -mt-0.5 -mr-0.5 p-0"
      phx-click="square-clicked"
      phx-value-grid-id={@id}
      disabled={@state != "" || not @your_turn?}
      >
      <%= @state %>
    </button>
    """
  end


  attr :history, :list, required: true
  def game_history(assigns) do
    ~H"""
    <div>
      <h2 class="font-bold">Game history</h2>
      <dl class="">
        <%= for h <- @history do %>
          <a phx-click="undo" phx-value-to-turn={h.turn}
             class="cursor-pointer hover:bg-zinc-100 flex gap-4">
            <dt>Turn <%= h.turn %></dt>
            <dd class=""><%= Calendar.strftime(h.time_stamp, "%X") %></dd>
            <dd class=""><%= h.log %></dd>
          </a>
        <% end %>
      </dl>
    </div>
    """
  end
end
