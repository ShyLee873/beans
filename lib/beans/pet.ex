defmodule Beans.Pet do
  use GenServer

  @topic "pet:beans"
  @hunger_tick 20_000

  @initial_state %{
    name: "Beans",
    hunger: 20,
    energy: 80,
    happiness: 75
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
    new_state = %{
      state
      | hunger: max(state.hunger - 20, 0),
        energy: max(state.energy + 10, 0)
    }

    |> broadcast()
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:play, _from, state) do
    new_state = %{
      state
      | happiness: min(state.happiness + 15, 100),
        energy: max(state.energy - 10, 0)
    }
    |> broadcast()
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:pet, _from, state) do
    new_state = %{state | happiness: min(state.happiness + 10, 100)}
    |> broadcast()
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_info(:hunger_tick, state) do
    new_state = %{state | hunger: min(state.hunger + 5, 1000)}

    schedule_hunger_tick()
    |> broadcast()
    {:noreply, new_state}
  end

  defp schedule_hunger_tick do
    Process.send_after(self(), :hunger_tick, @hunger_tick)
  end

  defp broadcast(new_state) do
    Phoenix.PubSub.broadcast(
      Beans.PubSub,
      @topic,
      {:pet_updated, new_state}
    )

    new_state
  end
end
