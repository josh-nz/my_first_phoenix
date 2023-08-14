defmodule MyFirstPhoenixWeb.RenderTest do
  use MyFirstPhoenixWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :foo, "foo")}
  end

  def handle_event("change_foo", _, socket) do
    # The following line causes :foo to be changed
    # but also casues any assign/3 in foo_render
    # to be considered as changed.
    socket = assign(socket, :foo, "foo")
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <.foo_render status={@foo} />
    <button phx-click="change_foo">Change Foo</button>
    """
  end

  def foo_render(%{status: foo} = assigns) do
    IO.inspect(assigns, label: "before")
    assigns = assign(assigns, :pattern_match, foo)
    assigns = assign(assigns, :new_var, "direct assigns")
    IO.inspect(assigns, label: "after")
    ~H"""
    <div>Foo: <%= @pattern_match %></div>
    """
  end
end
