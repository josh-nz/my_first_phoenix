defmodule MyFirstPhoenix.Tictactoe.GameContext do
  alias Phoenix.PubSub

  alias MyFirstPhoenix.Tictactoe.Game
  alias MyFirstPhoenix.Tictactoe.GameServer
  alias MyFirstPhoenix.Tictactoe.GameSupervisor


  def list_games() do
    GameSupervisor.list_games()
    |> Enum.map(&game_metadata/1)
    |> Enum.sort({:desc, Game})  # Calls compare/2 in Game module to sort Game structs.
    # |> Enum.sort_by(&(&1.game_id), :asc)  # Alternative, selecting field to sort by.
  end

  defp game_metadata(game_id) do
    GameServer.game_metadata(game_id)
  end

  def load_game(game_id) do
    try do
      {:ok, GameServer.load_game(game_id)}
    catch
      :exit, e -> {:error, e}
    end
  end

  def create_game!(current_user, params) do
    if (current_user == nil) do
      raise("Unauthenticated user cannot create game.")
    end

    # params = Map.put(params, Enum.random(["player_x", "player_o"]), current_user)

    changeset =
      %Game{}
      |> Map.put(Enum.random([:player_x, :player_o]), current_user)
      |> Game.changeset(params)
      # |> IO.inspect()

    case Ecto.Changeset.apply_action(changeset, :create_game) do
      {:ok, game} ->
        game = GameSupervisor.create_game!(game)
        broadcast("lobby", :new_game, game)
        {:ok, game}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def join_game(game_id, current_user) do
    if (current_user == nil) do
      raise("Unauthenticated user cannot join game.")
    end

    case GameServer.add_player(game_id, current_user) do
      {:ok, game} ->
        broadcast("lobby", :player_added, game)
        broadcast(game_id, :player_added, game)
      {:error, message} -> {:error, message}
    end
  end

  def take_turn(caller, game_id, grid_id) do
    turn = GameServer.take_turn(game_id, grid_id)
    Phoenix.PubSub.broadcast_from(MyFirstPhoenix.PubSub, caller, "tictactoe:#{game_id}", {:turn_taken, turn})
    turn
  end

  def rewind(caller, game_id, to_turn) do
    turns = GameServer.rewind(game_id, to_turn)
    Phoenix.PubSub.broadcast_from(MyFirstPhoenix.PubSub, caller, "tictactoe:#{game_id}", {:game_history_changed, turns})
    turns
  end



  def subscribe(topic) do
    PubSub.subscribe(MyFirstPhoenix.PubSub, "tictactoe:#{topic}")
  end

  defp broadcast(room, event, game) do
    PubSub.broadcast(MyFirstPhoenix.PubSub, "tictactoe:#{room}", {event, game})
  end
end
