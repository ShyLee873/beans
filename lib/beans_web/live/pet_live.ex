defmodule BeansWeb.PetLive do
  use BeansWeb, :live_view

  alias Beans.Pet

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Beans.PubSub, "pet:beans")
    end

    {:ok, assign(socket, :pet, Pet.get_state())}
  end

  @impl true
  def handle_event("feed", _params, socket) do
    Pet.feed()
    {:noreply, socket}
  end

  @impl true
  def handle_event("play", _params, socket) do
    Pet.play()
    {:noreply, socket}
  end

  @impl true
  def handle_event("pet", _params, socket) do
    Pet.pet()
    {:noreply, socket}
  end

  @impl true
  def handle_info({:pet, _updated, pet}, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex min-h-[80vh] items-center justify-center px-4 py-12">
      <main class="w-full max-w-lg">
        <div class="rounded-3xl border border-zinc-200 bg-white p-8 shadow-xl">
          <div class="text-center">
            <div class="text-7xl mb-4">
              {pet_face(@pet)}
            </div>

            <h1 class="text-4xl font-bold text-zinc-900">{@pet.name}</h1>

            <p class="mt-2 text-lg text-zinc-500">{mood(@pet)}</p>
          </div>

          <div class="mt-10 space-y-6">
            <.stat_bar
              label="Hunger"
              emoji="🍥"
              value={@pet.hunger}
            />

            <.stat_bar
              label="Energy"
              emoji="⚡"
              value={@pet.energy}
            />

            <.stat_bar
              label="Happiness"
              emoji="❤️"
              value={@pet.happiness}
            />
          </div>

          <div class="mt-10 grid grid-cols-3 gap-3">
            <button
              phx-click="feed"
              disabled={@pet.sleeping}
              class="rounded-xl bg-zinc-900 px-4 py-3 font-semibold text-white transition hover:bg-zinc-700"
            >
              🍥 Feed
            </button>

            <button
              phx-click="play"
              disabled={@pet.sleeping}
              class="rounded-xl bg-zinc-900 px-4 py-3 font-semibold text-white transition hover:bg-zinc-700"
            >
              🧶 Play
            </button>

            <button
              phx-click="pet"
              disabled={@pet.sleeping}
              class="rounded-xl bg-zinc-900 px-4 py-3 font-semibold text-white transition hover:bg-zinc-700"
            >
              🫳🏻 Pet
            </button>
          </div>

          <p class="mt-7 text-center text-sm text-zinc-400">Definitely not plotting anything...</p>
        </div>
      </main>
    </div>
    """
  end

  attr :label, :string, required: true
  attr :emoji, :string, required: true
  attr :value, :integer, required: true

  defp stat_bar(assigns) do
    ~H"""
    <div>
      <div class="mb-2 flex justify-between">
        <span class="font-medium text-zinc-700">{@emoji} {@label}</span>

        <span class="text-zinc-500">{@value}</span>

        <div class="h-4 overflow-hidden rounded-full bg-zinc-200">
          <div
            class="h-full rounded-full bg-zinc-900 transistion-all duration-300"
            style={"width: #{@value}"}
          >
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp pet_face(%{hunger: hunger}) when hunger >= 80, do: "😾"
  defp pet_face(%{energy: energy}) when energy <= 0, do: "😴"
  defp pet_face(%{happiness: happiness}) when happiness >= 90, do: "😸"
  defp pet_face(_pet), do: "🐱"

  defp mood(%{hunger: hunger}) when hunger >= 80, do: "Beans is hungry"
  defp mood(%{energy: energy}) when energy <= 10, do: "Beans is getting tired"
  defp mood(%{energy: energy}) when energy <= 0, do: "Beans is sleeping"
  defp mood(%{happiness: happiness}) when happiness >= 90, do: "Beans is happy"
  defp mood(%{hunger: hunger}) when hunger >= 50, do: "Beans could go for a snack"
  defp mood(_pet), do: "Beans is content"
end
