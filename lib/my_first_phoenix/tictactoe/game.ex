defmodule MyFirstPhoenix.Tictactoe.Game do
  use GenServer, restart: :temporary

  defmodule Turn do
    @enforce_keys [:turn, :board, :next_player, :status, :log, :time_stamp]
    defstruct [:turn, :board, :next_player, :status, :log, :time_stamp]
  end


  ## Client API

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(name))
  end

  def new_game(name) do
    name |> via_tuple |> GenServer.call(:new_game)
  end

  def take_turn(name, grid_id) do
    name |> via_tuple |> GenServer.call({:take_turn, grid_id})
  end

  def rewind(name, turn) do
    name |> via_tuple |> GenServer.call({:rewind, turn})
  end

  def load_game(id) do
    id |> via_tuple |> GenServer.call(:load_game)
  end


  ## GenServer callbacks

  @impl true
  def init(_init_arg) do
    {:ok, []}
  end

  @impl true
  def handle_call(:new_game, _from, _turns) do
    game = new_game()
    {:reply, game, game}
  end

  @impl true
  def handle_call({:take_turn, grid_id}, _from, turns) do
    %Turn{board: board, next_player: player} = hd(turns)
    new_board = Map.put(board, grid_id, player)

    {status, next_player} = game_over?(new_board, player)

    next_turn = %Turn{
      turn: length(turns),
      board: new_board,
      next_player: next_player,
      status: status,
      log: "Player #{player} placed in square #{grid_id}",
      time_stamp: nz_now()
    }

    {:reply, next_turn, [next_turn] ++ turns}
  end

  @impl true
  def handle_call({:rewind, turn}, _from, turns) do
    current_turn = length(turns)

    new_turns =
      case turn do
        x when x >= current_turn or x < 0 -> turns  # guard against invalid turn
        _ -> Enum.slice(turns, (current_turn - turn - 1)..9)
      end

    {:reply, new_turns, new_turns}
  end

  @impl true
  def handle_call(:load_game, _from, turns) do
    {:reply, turns, turns}
  end


  defp new_game() do
    board = %{
      1 => "", 2 => "", 3 => "",
      4 => "", 5 => "", 6 => "",
      7 => "", 8 => "", 9 => ""
    }

    [%Turn{
      turn: 0,
      board: board,
      next_player: "X",
      status: :undecided,
      log: "Initialised new game.",
      time_stamp: nz_now()
    }]
  end

  defp nz_now() do
    DateTime.now!("Pacific/Auckland")
  end

  defp next_player("X"), do: "O"
  defp next_player("O"), do: "X"

  defp game_over?(board, player) do
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

    player_has_won = Enum.any?(winning_lines, fn [a, b, c] ->
      board[a] != "" and board[a] == board[b] and board[a] == board[c]
    end)

    board_is_full = not Enum.any?(board, fn {_, v} -> v == "" end)

    cond do
      player_has_won -> {:winner, player}
      board_is_full -> {:stalemate, nil}
      true -> {:undecided, next_player(player)}
    end
  end

  defp via_tuple(name) do
    {:via, Registry, {MyFirstPhoenix.Tictactoe.GameRegistry, name}}
  end
end
