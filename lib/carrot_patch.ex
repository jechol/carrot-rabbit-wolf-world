defmodule CarrotPatch do
  import CarrotPatch.Grower
  import CarrotPatch.Killer

  # use GenServer

  defstruct [:has_carrots, :x, :y, :carrot_growth_points, :carrot_age, :occupant, :board_size]

  @emoji_number 127823
  @grow_tick_interval 500
  @update_world_interval 1000
  @carrot_growth_points_required 100
  @carrot_graphic "."
  @occupant_graphic "R"

  def start(%{x: x, y: y, board_size: board_size}) do
    {:ok, pid} = GenServer.start_link(CarrotPatch, %{x: x, y: y, board_size: board_size})
    :timer.send_interval(@grow_tick_interval, pid, :grow_tick)
    :timer.send_interval(@update_world_interval, pid, :update_world_tick)
    {:ok, pid}
  end

  def coordinates(pid) do
    GenServer.call(pid, {:get, :coordinates})
  end

  def eat_carrots(pid) do
    response = GenServer.call(pid, :eat_carrots)
    {:ok, response}
  end

  def register_occupant({carrot_patch, occupant}) do
    GenServer.cast(carrot_patch, {:put, {:occupant, occupant}})
  end

  def occupant_arrived({carrot_patch, occupant}) do
    GenServer.cast(carrot_patch, {:put, {:occupant, occupant}})
  end

  def occupant_left({carrot_patch, occupant}) do
    GenServer.cast(carrot_patch, {:delete, {:occupant, occupant}})
  end
  
  def to_screen(%{has_carrots: has_carrots, occupant: occupant}) do
    cond do
      occupant ->    @occupant_graphic
      has_carrots -> @carrot_graphic
      :else ->       " "
    end
  end
  
  

  # =============== Server Callbacks

  def init(%{x: x, y: y, board_size: board_size}) do
    seed = {x+y, :erlang.monotonic_time, :erlang.unique_integer}
    :random.seed(seed)
    carrot_growth_points = :random.uniform(@carrot_growth_points_required)
    {:ok, %CarrotPatch{has_carrots: false, x: x, y: y, carrot_growth_points: carrot_growth_points, carrot_age: 0, board_size: board_size}}
  end

  def handle_info(:grow_tick, state) do
    {:noreply, tick_world(state)}
  end

  def handle_info(:update_world_tick, state) do
    {:noreply, update_world(state)}
  end

  def handle_call({:get, :coordinates}, _, state = %CarrotPatch{x: x, y: y}) do
    reply = %{x: x, y: y}
    {:reply, reply, state}
  end

  def handle_call(:eat_carrots, _, state = %CarrotPatch{}) do
    {reply, new_state} = do_eat_carrots(state)
    {:reply, reply, new_state}
  end

  def handle_cast({:delete, {:occupant, _}}, state = %CarrotPatch{}) do
    new_state = %CarrotPatch{state | occupant: nil}
    {:noreply, new_state}
  end

  def handle_cast({:put, {:occupant, occupant}}, state = %CarrotPatch{}) do
    new_state = %CarrotPatch{state | occupant: occupant}
    {:noreply, new_state}
  end

  def terminate(reason, state) do
    IO.puts "terminated CarrotPatch"
    IO.inspect reason
    IO.inspect state
    :ok
  end

  

  # =============== Private functions

  def do_eat_carrots(state = %CarrotPatch{has_carrots: has_carrots}) do
    cond do
      has_carrots ->
        {true, %{state | has_carrots: false, carrot_growth_points: 0, carrot_age: 0}}
      :else ->
        {false, state}
    end
  end

  defp tick_world(state) do
    state
    |> grow_and_recognize_new_carrots    
    |> age_existing_and_kill_carrots
  end

  defp update_world(state = %CarrotPatch{x: x, y: y, has_carrots: has_carrots, occupant: occupant}) do
    graphics = CarrotPatch.to_screen(%{has_carrots: has_carrots, occupant: occupant})
    CarrotWorldServer.put_patch(%{x: x, y: y, graphics: graphics})
    state
  end

end