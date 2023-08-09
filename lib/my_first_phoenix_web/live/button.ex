defmodule MyFirstPhoenixWeb.Button do
  use MyFirstPhoenixWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{"name" => nil}), disabled: true)}
  end

  def handle_event("name-changed", %{"name" => name} = params, socket) do
    IO.inspect(params)
    disabled = name == nil or String.trim(name) == ""
    {:noreply, assign(socket, disabled: disabled)}
  end

  def render(assigns) do
    ~H"""
    <.form for={@form} phx-change="name-changed">
      <.input field={@form[:name]} />
      <.button type="submit" disabled={@disabled}>Save</.button>
    </.form>
    """
  end
end
