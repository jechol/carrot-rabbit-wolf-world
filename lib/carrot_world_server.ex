defmodule CarrotWorldServer do
  use GenServer

  @world_tick 100

  def start(%{board_size: board_size}) do
    GenServer.start_link(CarrotWorldServer, {:board_size, board_size}, name: :carrot_world_server)
    {:ok, :carrot_world_server}
  end

  def start_in_production do
    start(%{board_size: 30})
  end

  def sip do
    {:ok, :carrot_world_server} = start_in_production
    :timer.send_interval(@world_tick, :carrot_world_server, :tick)
  end
  

  def render_map do
    GenServer.call(:carrot_world_server, {:get, :map})
  end

  def put_patch(%{x: x, y: y, graphics: graphics}) do
    GenServer.cast(:carrot_world_server, {:put_patch, %{x: x, y: y, graphics: graphics}})
  end

  def carrot_patch_at(%{x: x, y: y}) do
    GenServer.call(:carrot_world_server, {:get_patch_at, %{x: x, y: y}})
  end

  def move_rabbit(rabbit, {old_coordinates, new_coordinates}) do
    new_patch = carrot_patch_at(new_coordinates)
    old_patch = carrot_patch_at(old_coordinates)
    
    CarrotPatch.occupant_arrived({new_patch, rabbit})
    CarrotPatch.occupant_left({old_patch, rabbit})
  end

  def move_rabbit(rabbit, new_coordinates) do
    new_patch = carrot_patch_at(new_coordinates)
    CarrotPatch.occupant_arrived({new_patch, rabbit})
  end  
  
  
  # ===============

  def init({:board_size, board_size}) do
    state = CarrotWorld.build_initial_world({:board_size, board_size})
    {:ok, state}
  end

  def handle_call({:get, :map}, _, state = %{board: board}) do
    {:reply, board, state}
  end

  def handle_call({:get_patch_at, %{x: x, y: y}}, _, state = %{carrot_patches: carrot_patches}) do
    carrot_patch = CarrotWorld.find_at(carrot_patches, %{x: x, y: y})
    {:reply, carrot_patch, state}
  end

  def handle_cast({:put_patch, %{x: x, y: y, graphics: graphics}}, state = %{board: board}) do
    new_board = CarrotWorld.replace_at(board, %{x: x, y: y}, graphics)
    new_state = %CarrotWorld{state | board: new_board}
    {:noreply, new_state}
  end

  def handle_info(:tick, state = %{board: board}) do
    board
    |> Enum.each(fn(row) -> IO.puts(Enum.join(row, " ")) end)

    IO.puts ""
    IO.puts ""
    {:noreply, state}
  end
  
  
end
