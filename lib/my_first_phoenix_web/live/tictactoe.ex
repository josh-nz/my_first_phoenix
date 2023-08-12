defmodule MyFirstPhoenixWeb.TicTacToe do
  use MyFirstPhoenixWeb, :live_view

  defmodule History do
    @enforce_keys [:id, :board, :log, :time_stamp]
    defstruct [:id, :board, :log, :time_stamp]
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, new_game())}
  end

  def handle_event("reset", _, socket) do
    {:noreply, assign(socket, new_game())}
  end

  def handle_event("square-clicked", %{"grid-id" => grid_id_str}, socket) do
    grid_id = String.to_integer(grid_id_str)
    [%History{board: board} | _] = socket.assigns.game_state
    player = socket.assigns.player

    socket = maybe_update_board(socket, grid_id, board, player, board[grid_id])
    IO.inspect(socket.assigns)
    {:noreply, socket}

    # {:noreply, socket
    #   |> maybe_update_board(grid_id, board, player, board[grid_id])
    # }
  end

  defp maybe_update_board(socket, grid_id, board, player, "") do
    new_board = Map.put(board, grid_id, player)

    new_game_state = [%History{
      id: length(socket.assigns.game_state),
      board: new_board,
      log: "Player #{player} placed in square #{grid_id}",
      time_stamp: nz_now()
    }]

    IO.inspect(new_game_state)

    game_over = game_over?(new_board)

    assign(socket,
      player: if(game_over, do: player, else: next_player(player)),
      board: new_board,
      game_state: new_game_state ++ socket.assigns.game_state,
      game_over: game_over
    )
  end

  defp maybe_update_board(socket, _grid_id, _board, _player, _board_value) do
    socket
  end

  defp next_player("X"), do: "O"
  defp next_player("O"), do: "X"

  defp game_over?(board) do
    winning_lines = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
      [1, 4, 7],
      [2, 5, 8],
      [3, 6, 9],
      [1, 5, 9],
      [3, 5, 7]
    ]

    Enum.any?(winning_lines, fn [a, b, c] ->
      board[a] != "" and board[a] == board[b] and board[a] == board[c]
    end)
  end

  defp new_game() do
    board = %{
      1 => "", 2 => "", 3 => "",
      4 => "", 5 => "", 6 => "",
      7 => "", 8 => "", 9 => ""
    }

    %{player: "X",
      board: board,
      game_state: [%History{id: 0, board: board, log: "Initialised new game.", time_stamp: nz_now()}],
      game_over: false
    }
  end

  defp nz_now() do
    DateTime.now!("Pacific/Auckland")
  end

  def render(assigns) do
    ~H"""
    <h1 class="font-bold">Tic Tac Toe</h1>
    <div :if={@game_over}>
      <p>Game over. Winner was player <%= @player %></p>
      <.button phx-click="reset" >New game</.button>
    </div>
    <div :if={not @game_over}>Current player: <%= @player %></div>

    <.board_row indexes={[1,2,3]} board={@board} disabled={@game_over} />
    <.board_row indexes={[4,5,6]} board={@board} disabled={@game_over} />
    <.board_row indexes={[7,8,9]} board={@board} disabled={@game_over} />

    <.game_history history={@game_state} />
    """
  end

  attr :indexes, :list, required: true
  attr :board, :map, required: true
  attr :disabled, :boolean, required: true
  def board_row(assigns) do
    ~H"""
    <div class="flex flex-row">
      <.square :for={n <- @indexes} id={n} state={@board[n]} disabled={@disabled} />
    </div>
    """
  end

  attr :id, :string, required: true
  attr :state, :string, required: true
  attr :disabled, :boolean, required: true
  def square(assigns) do
    ~H"""
    <button
      class="border border-black text-2xl font-bold text-center h-8 w-8 -mt-0.5 -mr-0.5 p-0"
      phx-click="square-clicked"
      phx-value-grid-id={@id}
      disabled={@disabled}
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
      <dl class="grid grid-cols-[max-content_max-content_1fr] gap-x-4">
        <%= for h <- @history do %>
          <dt>Turn <%= h.id %></dt>
          <dd class=""><%= Calendar.strftime(h.time_stamp, "%X") %></dd>
          <dd class=""><%= h.log %></dd>
        <% end %>
      </dl>
    </div>
    """
  end


end
