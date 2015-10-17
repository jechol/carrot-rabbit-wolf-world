
require IEx
defmodule Rabbit do

  # use GenServer

  defstruct [:current_coordinates, :board_size, :carrots_in_belly, :days_since_last_carrots, :alive]

  @move_tick_interval 500
  @carrots_in_belly_before_reproduce 5
  @day_can_live_without_carrots 10

  # Dies after 10 rounds with no carrots

  def start(starting_coordinates, board_size: board_size) do
    {:ok, pid} = GenServer.start_link(Rabbit, %{current_coordinates: starting_coordinates, board_size: board_size})
    :timer.send_interval(@move_tick_interval, pid, :move_tick)
    {:ok, pid}
  end

  def coordinates(pid) do
    GenServer.call(pid, {:get, :coordinates})
  end

  # =============== Server Callbacks

  def init(%{current_coordinates: coordinates, board_size: board_size}) do
    {:ok, %Rabbit{current_coordinates: coordinates, board_size: board_size, carrots_in_belly: 0, days_since_last_carrots: 0, alive: true}}
  end

  def handle_info(:move_tick, state) do
    new_state = tick_world(state)
    cond do
      new_state.alive ->
        {:noreply, new_state}
      :else ->
        {:stop, :normal, new_state}
    end
  end

  def handle_call({:get, :coordinates}, _, state = %Rabbit{current_coordinates: %{x: x, y: y}}) do
    reply = %{x: x, y: y}
    {:reply, reply, state}
  end

  def terminate(:normal, state) do
    CarrotWorldServer.remove_rabbit(self, state.current_coordinates)
    :ok
  end

  def terminate(reason, state) do
    IO.puts "terminated Rabbit"
    IO.inspect reason
    IO.inspect state
    :ok
  end
  
  # =============== Private functions

  def tick_world(state) do
    state
    |> move_patches
    |> try_to_eat_carrots
    |> make_babies
    |> age
    |> die
  end

  def age(state) do
    %Rabbit{state | days_since_last_carrots: state.days_since_last_carrots + 1}
  end

  def die(state) do
    cond do
      state.days_since_last_carrots > @day_can_live_without_carrots ->
        %Rabbit{state | alive: false}
      :else ->
        state
    end
  end

  def make_babies(state) do
    cond do
     state.carrots_in_belly > @carrots_in_belly_before_reproduce ->
      starting_coordinates = state.current_coordinates
      Rabbit.start(starting_coordinates, board_size: state.board_size)
      %Rabbit{state | carrots_in_belly: 0}
    :else ->
      state
    end
  end

  def try_to_eat_carrots(state) do
    {:ok, carrots_found} = CarrotWorldServer.rabbit_eat_carrots(self, state.current_coordinates)
    cond do
      carrots_found -> eat_carrots(state)
      :else -> state
    end
  end

  def eat_carrots(state) do
    %Rabbit{state | carrots_in_belly: state.carrots_in_belly + 1, days_since_last_carrots: 0}
  end

  def move_patches(state) do
    next_coordinates = next_coordinates(state)

    current_coordinates = state.current_coordinates

    enter_and_leave({current_coordinates, next_coordinates})
        
    %Rabbit{state | current_coordinates: next_coordinates}
  end

  def enter_and_leave({old_coordinates, new_coordinates}) do
    CarrotWorldServer.move_rabbit(self, {old_coordinates, new_coordinates})
  end

  def next_coordinates(state) do
    valid_neighbor_patches(state) 
      |> Enum.shuffle
      |> List.first
  end

  defp carrot_patch_finder do
    CarrotWorldServer
  end

  def valid_neighbor_patches(state) do
    board_size = state.board_size
    all_theoritical_neighboring_coordinates(state)
    |> Enum.filter(fn(coords) -> not_off_the_board(coords, board_size) end)
  end

  defp all_theoritical_neighboring_coordinates(state) do
    %{x: x, y: y} = state.current_coordinates
    [
      %{x: x - 1, y: y - 1},
      %{x: x - 1, y: y},
      %{x: x - 1, y: y + 1},
      %{x: x, y: y - 1},
      %{x: x, y: y + 1},
      %{x: x + 1, y: y - 1},
      %{x: x + 1, y: y},
      %{x: x + 1, y: y + 1},
    ]
  end

  defp not_off_the_board(%{x: x, y: _}, board_size) when x < 0, do: false
  defp not_off_the_board(%{x: _, y: y}, board_size) when y < 0, do: false
  defp not_off_the_board(%{x: x, y: _}, board_size) when x >= board_size, do: false
  defp not_off_the_board(%{x: _, y: y}, board_size) when y >= board_size, do: false
  defp not_off_the_board(%{x: _, y: _}, board_size), do: true
  
  
end