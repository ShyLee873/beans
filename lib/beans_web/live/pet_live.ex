defmodule BeansWeb.PetLive do
  use BeansWeb, :live_view

  alias Beans.Pet

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Beans.PubSub, "pet:beans")
    end

    {:ok,
    socket
    |> assign(:pet, Pet.get_state())
    |> assign(:giphy_api_key, Application.fetch_env!(:beans, :giphy_api_key))}
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
  def handle_info({:pet_updated, pet}, socket) do
    {:noreply, assign(socket, :pet, pet)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex min-h-[80vh] items-center justify-center px-4 py-12">
      <main class="w-full max-w-lg">
        <div class="rounded-3xl border border-zinc-200 bg-white p-8 shadow-xl">
          <% beans_mood = mood(@pet) %>
          <div class="text-center">
            <h1 class="text-4xl font-bold text-zinc-900 mb-4">{@pet.name}</h1>
            <div
              id="beans-gif"
              phx-hook="BeansMood"
              data-query={beans_mood.gif_query}
              data-api-key={@giphy_api_key}
              class="flex items-center justify-center mb-4"
            >
            {pet_face(@pet)}
            </div>

            <p class="mt-2 text-lg text-zinc-500">{beans_mood.text}</p>
          </div>

          <div class="ml-22 mt-10 space-y-6">
            <.stat_bar
              label="Hunger"
              emoji="🍥"
              value={"#{@pet.hunger} %"}
            />

            <.stat_bar
              label="Energy"
              emoji="⚡"
              value={"#{@pet.energy} %"}
            />

            <.stat_bar
              label="Happiness"
              emoji="❤️"
              value={"#{@pet.happiness} %"}
            />
          </div>

          <div class="mt-10 grid grid-cols-3 gap-3">
            <button
              phx-click="feed"
              disabled={@pet.sleeping}
              class="rounded-xl bg-zinc-900 px-4 py-3 font-semibold text-white transition hover:bg-zinc-700 disabled:opacity-50 disabled:pointer-events-none"
            >
              🍥 Feed
            </button>

            <button
              phx-click="play"
              disabled={@pet.sleeping}
              class="rounded-xl bg-zinc-900 px-4 py-3 font-semibold text-white transition hover:bg-zinc-700 disabled:opacity-50 disabled:pointer-events-none"
            >
              🧶 Play
            </button>

            <button
              phx-click="pet"
              disabled={@pet.sleeping}
              class="rounded-xl bg-zinc-900 px-4 py-3 font-semibold text-white transition hover:bg-zinc-700 disabled:opacity-50 disabled:pointer-events-none"
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

  # This will be replaced with js and giphy's api
  defp pet_face(%{hunger: hunger}) when hunger >= 80, do: "😾"
  defp pet_face(%{energy: energy}) when energy <= 0, do: "😴"
  defp pet_face(%{happiness: happiness}) when happiness >= 90, do: "😸"
  defp pet_face(_pet), do: "🐱"

  defp mood(%{hunger: hunger, happiness: happiness, sleeping: sleeping}) when hunger >= 80 and happiness <= 10 and sleeping,
    do: %{
      text: "Beans is sleeping away the lonliness 🥺",
      gif_query: "sad sleeping cat"
    }

  defp mood(%{hunger: hunger, happiness: happiness, sleeping: sleeping}) when hunger >= 80 and happiness <= 40 and sleeping,
    do: %{
      text: "Beans is having an angry nap (But he still loves you)",
      gif_query: "grumpy sleeping cat"
    }

  defp mood(%{energy: energy}) when energy == 0,
    do: %{
      text: "Beans is sleeping",
      gif_query: "happy sleeping cat"
    }

  defp mood(%{hunger: hunger}) when hunger >= 80,
    do: %{
      text: "Beans is hungry",
      gif_query: "hungry cat"
    }

  defp mood(%{energy: energy}) when energy <= 10,
    do: %{
      text: "Beans needs a nap",
      gif_query: "sleepy cat"
    }

  defp mood(%{energy: energy}) when energy <= 20,
    do: %{
      text: "Beans is getting tired",
      gif_query: "yawning cat"
    }

  defp mood(%{happiness: happiness}) when happiness <= 20,
    do: %{
      text: "Beans is so very sad",
      gif_query: "sad cat"
    }

  defp mood(%{happiness: happiness}) when happiness <= 50,
    do: %{
      text: "Beans needs a cuddle",
      gif_query: "cat pet me needy"
    }

  defp mood(%{happiness: happiness}) when happiness <= 80,
    do: %{
      text: "Beans would like a cuddle",
      gif_query: "cat attention"
    }

  defp mood(%{happiness: happiness}) when happiness >= 90,
    do: %{
      text: "Beans is happy",
      gif_query: "happy cat purr"
    }

  defp mood(%{hunger: hunger}) when hunger >= 50,
    do: %{
      text: "Beans could go for a snack",
      gif_query: "hungry cat feed me"
    }
  defp mood(_pet),
    do: %{
      text: "Beans is content",
      gif_query: "happy cat"
    }
end
