defmodule MyFirstPhoenixWeb.Tictactoe.Game do
  use MyFirstPhoenixWeb, :live_view

  alias MyFirstPhoenix.Tictactoe.Game, as: G
  alias MyFirstPhoenix.Tictactoe.GameSupervisor

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    result = GameSupervisor.create_game(id)

    turns =
      case result do
        {:ok, _} -> G.new_game(id)
        {:error, {:already_started, _pid}} -> G.load_game(id)
      end

    {:ok, assign(socket, %{
      id: id,
      current_turn: hd(turns),
      game_turns: turns
    })}
  end

  @impl true
  def handle_event("reset", _, socket) do
    # {:noreply, socket}
    turns = G.new_game(socket.assigns.id)
    {:noreply, assign(socket, %{
      current_turn: hd(turns),
      game_turns: turns
    })}
  end

  def handle_event("square-clicked", %{"grid-id" => grid_id_str}, socket) do
    grid_id = String.to_integer(grid_id_str)

    turn = G.take_turn(socket.assigns.id, grid_id)

    {:noreply, assign(socket, %{
      current_turn: turn,
      game_turns: [turn] ++ socket.assigns.game_turns
    })}
  end

  def handle_event("undo", %{"turn" => turn_str}, socket) do
    turn = String.to_integer(turn_str)

    turns = G.rewind(socket.assigns.id, turn)

    {:noreply, assign(socket, %{
      current_turn: hd(turns),
      game_turns: turns
    })}
  end



  @impl true
  def render(assigns) do
    ~H"""
    <h1 class="font-bold">Tic Tac Toe</h1>

    <.game_status game_status={@current_turn.status} player={@current_turn.next_player}  />

    <.board_row indexes={[1,2,3]} board={@current_turn.board} />
    <.board_row indexes={[4,5,6]} board={@current_turn.board} />
    <.board_row indexes={[7,8,9]} board={@current_turn.board} />

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
      <.button phx-click="reset">New game</.button>
    </div>
    """
  end


  attr :indexes, :list, required: true
  attr :board, :map, required: true
  def board_row(assigns) do
    ~H"""
    <div class="flex flex-row">
      <.square :for={n <- @indexes} id={n} state={@board[n]} />
    </div>
    """
  end


  attr :id, :string, required: true
  attr :state, :string, required: true
  def square(assigns) do
    ~H"""
    <button
      class="border border-black text-2xl font-bold text-center h-8 w-8 -mt-0.5 -mr-0.5 p-0"
      phx-click="square-clicked"
      phx-value-grid-id={@id}
      disabled={@state != ""}
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
          <a phx-click="undo" phx-value-turn={h.turn}
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
