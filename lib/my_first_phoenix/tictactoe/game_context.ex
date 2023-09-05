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
      :exit, e ->
        {:error, e}
      end
  end

  def create_game(current_user, params) do
    if (current_user == nil) do
      raise("Unauthenticated user cannot create game.")
    end

    # params = Map.put(params, Enum.random(["player_x", "player_o"]), current_user)
    %Game{}
    |> Map.put(Enum.random([:player_x, :player_o]), current_user)
    |> Game.changeset(params)
    |> IO.inspect()
    |> Ecto.Changeset.apply_action(:create_game)
    |> GameSupervisor.create_game()
    |> broadcast(:new_game, "lobby")
  end

  def join_game(game_id, current_user) do
    if (current_user == nil) do
      raise("Unauthenticated user cannot join game.")
    end

    GameServer.add_player(game_id, current_user)
    |> broadcast(:player_added, "lobby")
    |> broadcast(:player_added, game_id)
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

  defp broadcast({:error, _} = error, _event, _room), do: error
  defp broadcast({:ok, game} = ok, event, room) do
    PubSub.broadcast(MyFirstPhoenix.PubSub, "tictactoe:#{room}", {event, game})
    ok
  end
end
