
defmodule CarrotPatch do

  defstruct [:has_carrots, :x, :y]

  @emoji_number 127823
  @world_tick 500

  def start(%{x: x, y: y}) do
    {:ok, pid} = GenServer.start_link(CarrotPatch, %{x: x, y: y})
    :timer.send_interval(@world_tick, pid, :tick)
    {:ok, pid}
  end

  def has_carrots?(pid) do
    GenServer.call(pid, {:get, :has_carrots})
  end

  def grow_carrots(pid) do
    GenServer.cast(pid, {:put, :new_carrots})
  end

  def remove_carrots(pid) do
    GenServer.cast(pid, {:put, :remove_carrots})
  end

  def to_screen(pid) do
    has_carrots = GenServer.call(pid, {:get, :has_carrots})
    cond do
      has_carrots -> "1"
      :else -> "0"
    end
  end

  def coordinates(pid) do
    GenServer.call(pid, {:get, :coordinates})
  end
  
  

  # =============== Server Callbacks

  def init(%{x: x, y: y}) do
    {:ok, %CarrotPatch{has_carrots: false, x: x, y: y}}
  end

  def handle_info(:tick, state) do
    {:noreply, tick_world(state)}
  end

  def handle_call({:get, :has_carrots}, _, state = %CarrotPatch{has_carrots: has_carrots}) do
    {:reply, has_carrots, state}
  end

  def handle_call({:get, :coordinates}, _, state = %CarrotPatch{x: x, y: y}) do
    reply = %{x: x, y: y}
    {:reply, reply, state}
  end

  def handle_cast({:put, :new_carrots}, state = %CarrotPatch{}) do
    new_state = %CarrotPatch{state | :has_carrots => true}
    {:noreply, new_state}
  end

  def handle_cast({:put, :remove_carrots}, state = %CarrotPatch{}) do
    new_state = %CarrotPatch{state | :has_carrots => false}
    {:noreply, new_state}
  end

  # =============== Private functions

  defp tick_world(state) do
    
  end
  
end