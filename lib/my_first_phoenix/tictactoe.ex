defmodule MyFirstPhoenix.Tictactoe do
  use GenServer, restart: :temporary

  defmodule Turn do
    @enforce_keys [:turn, :board, :next_player, :status, :log, :time_stamp]
    defstruct [:turn, :board, :next_player, :status, :log, :time_stamp]
  end

  def register_game(name) do
    result = DynamicSupervisor.start_child(
      MyFirstPhoenix.GamesSupervisor,
      {MyFirstPhoenix.Tictactoe, name: build_registry_name(name)})

    game_pid =
      case result do
        {:ok, game_pid} -> game_pid
        {:error, {:already_started, game_pid}} -> game_pid
      end

    {game_pid, new_game(game_pid)}
  end

  defp build_registry_name(name) do
    {:via, Registry, {MyFirstPhoenix.GamesRegistry, name}}
  end

  # Client API

  def start_link(opts) do
    _ = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def new_game(game_pid) do
    GenServer.call(game_pid, :new_game)
  end

  def take_turn(game_pid, grid_id) do
    GenServer.call(game_pid, {:take_turn, grid_id})
  end

  def rewind(game_pid, turn) do
    GenServer.call(game_pid, {:rewind, turn})
  end

  # GenServer callbacks

  @impl true
  def init(:ok) do
    {:ok, []}
  end

  @impl true
  def handle_call(:new_game, _from, _turns) do
    game = new_game()
    {:reply, game, game}
  end

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

  def handle_call({:rewind, turn}, _from, turns) do
    current_turn = length(turns)

    new_turns =
      case turn do
        x when x >= current_turn or x < 0 -> turns  # guard against invalid turn
        _ -> Enum.slice(turns, (current_turn - turn - 1)..9)
      end

    {:reply, new_turns, new_turns}
  end

  def new_game() do
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

  # def take_turn(turns, grid_id) do
  #   %Turn{board: board, next_player: player} = hd(turns)
  #   new_board = Map.put(board, grid_id, player)

  #   {status, next_player} = game_over?(new_board, player)

  #   next_turn = %Turn{
  #     turn: length(turns),
  #     board: new_board,
  #     next_player: next_player,
  #     status: status,
  #     log: "Player #{player} placed in square #{grid_id}",
  #     time_stamp: nz_now()
  #   }

  #   [next_turn] ++ turns
  # end

  # def rewind(turns, turn) do
  #   current_turn = length(turns)

  #   case turn do
  #     x when x >= current_turn or x < 0 -> turns  # guard against invalid turn
  #     _ -> Enum.slice(turns, (current_turn - turn - 1)..9)
  #   end
  # end

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
end
