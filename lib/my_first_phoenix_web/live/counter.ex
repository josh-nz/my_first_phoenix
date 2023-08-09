defmodule MyFirstPhoenixWeb.Counter do
  use MyFirstPhoenixWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, value: 0, name: nil, form: to_form(%{"name" => nil}))}
  end

  def handle_params(params, _uri, socket) do
    current_value = socket.assigns.value
    socket = case params["direction"] do
      "up" ->
        current_value = if current_value === 9, do: 0, else: current_value + 1
        assign(socket, value: current_value)
      "down" ->
        current_value = if current_value === 0, do: 9, else: current_value - 1
        assign(socket, value: current_value)
      _ -> socket
    end

    {:noreply, socket}
  end

  def handle_event("dec", _value, socket) do
    current_value = socket.assigns.value
    current_value = if current_value === 0, do: 9, else: current_value - 1
    {:noreply, assign(socket, value: current_value)}
  end

  def handle_event("inc", _value, socket) do
    current_value = socket.assigns.value
    current_value = if current_value === 9, do: 0, else: current_value + 1
    {:noreply, assign(socket, value: current_value)}
  end

  def handle_event("name-changed", %{"name" => name}, socket) do
    #IO.inspect(socket.assigns)
    # Probably don't want to keep updaing the form like this, since it
    # causes a rerender.
    #{:noreply, assign(socket, name: name, form: to_form(%{"name" => name}))}
    {:noreply, assign(socket, name: name)}
  end

  def handle_event("name-changed-no-form", %{"key" => key}, socket) do
    {:noreply, assign(socket, name: (socket.assigns.name || "") <> key)}
  end

  def render(assigns) do
    ~H"""
    <div>Current value: <%= @value %></div>
    <div>
      <.link patch={~p"/counter?#{[direction: :down]}"}>Decrease</.link>
      <.link patch={~p"/counter?#{[direction: :up]}"}>Increase</.link>
    </div>
    <div>
      <a phx-click="dec" class="cursor-pointer">No qParams decrease</a>
      <.link phx-click="inc">No qParams increase</.link>
    </div>
    <div>Name: <%= @name %></div>
    <.form for={@form} phx-change="name-changed">
      <.input field={@form[:name]} />
    </.form>
    <div>
      <%= Phoenix.HTML.Form.text_input :noform, :standalone, [{"phx-keydown", "name-changed-no-form"}] %>
    </div>
    """
  end
end
