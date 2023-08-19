defmodule MyFirstPhoenix.Tictactoe do

  defmodule Turn do
    @enforce_keys [:turn, :board, :next_player, :status, :log, :time_stamp]
    defstruct [:turn, :board, :next_player, :status, :log, :time_stamp]
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

  def take_turn(turns, grid_id) do
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

    [next_turn] ++ turns
  end

  def rewind(turns, turn) do
    current_turn = length(turns)

    case turn do
      x when x >= current_turn or x < 0 -> turns  # guard against invalid turn
      _ -> Enum.slice(turns, (current_turn - turn - 1)..9)
    end
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
end
