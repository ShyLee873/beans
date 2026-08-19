defmodule Beans.Pet do
  use GenServer

  @topic "pet:beans"
  @hunger_tick 20_000
  @sleep_duration 10_000

  @initial_state %{
    name: "Beans",
    hunger: 20,
    energy: 80,
    happiness: 75,
    sleeping: false
  }

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, @initial_state, Keyword.put_new(opts, :name, __MODULE__))
  end

  def get_state do
    GenServer.call(__MODULE__, :get_state)
  end

  def feed do
    GenServer.call(__MODULE__, :feed)
  end

  def play do
    GenServer.call(__MODULE__, :play)
  end

  def pet do
    GenServer.call(__MODULE__, :pet)
  end

  @impl true
  def init(state) do
    schedule_hunger_tick()
    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:feed, _from, state) do
    new_state =
      %{
        state
        | hunger: clamp(state.hunger - 20),
          energy: clamp(state.energy + 25)
      }
      |> broadcast()

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:play, _from, state) do
    new_state =
      %{
        state
        | happiness: clamp(state.happiness + 15),
          energy: clamp(state.energy - 15),
          hunger: clamp(state.hunger + 5)
      }
      |> broadcast()

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:pet, _from, state) do
    new_state =
      %{state | happiness: clamp(state.happiness + 15)}
      |> broadcast()

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_info(:hunger_tick, state) do
    new_state = %{
      state
      | hunger: clamp(state.hunger + 5),
        energy: clamp(state.energy - 5),
        happiness: clamp(state.happiness - 5)
    }
    |> maybe_start_sleep()
    |> broadcast()
    
    schedule_hunger_tick()

    {:noreply, new_state}
  end

  @impl true
  def handle_info(:wake_up, state) do
    new_state = %{
      state
      | energy: 20,
        hunger: clamp(state.hunger + 10),
        happiness: clamp(state.happiness - 10),
        sleeping: false
    }
    {:noreply, new_state}
  end

  defp schedule_hunger_tick do
    Process.send_after(self(), :hunger_tick, @hunger_tick)
  end

  defp maybe_start_sleep(%{energy: 0, sleeping: false} = state) do
    schedule_wake()

    %{state | sleeping: true}
  end

  defp maybe_start_sleep(state), do: state

  defp schedule_wake do
    Process.send_after(self(), :wake_up, @sleep_duration)
  end

  defp broadcast(new_state) do
    Phoenix.PubSub.broadcast(
      Beans.PubSub,
      @topic,
      {:pet_updated, new_state}
    )

    new_state
  end

  defp clamp(value) do
    value
    |> max(0)
    |> min(100)
  end
end
