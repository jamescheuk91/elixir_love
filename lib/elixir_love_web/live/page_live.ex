defmodule ElixirLoveWeb.PageLive do
  use ElixirLoveWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(bindings: [], outputs: [])}
  end

  @impl Phoenix.LiveView
  def handle_event("execute", %{"command" => %{"text" => command}}, socket) do
    IO.inspect(command)
    {:ok, ast} = Code.string_to_quoted(command) |> IO.inspect()
    {result, bindings} = Code.eval_quoted(ast, socket.assigns.bindings, []) |> IO.inspect()

    outputs = socket.assigns.outputs ++ ["iex> " <> command] ++ [inspect(result)]
    socket = socket
        |> push_event("command", %{text: ""})
        |> assign(bindings: bindings, outputs: outputs)
    {:noreply, socket}
  end

end
