defmodule ElixirLoveWeb.PageLive do
  use ElixirLoveWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket |> assign(bindings: [], outputs: [])}
  end

  @impl Phoenix.LiveView
  def handle_event("execute", %{"command" => %{"text" => command}}, socket) do
    formatted_result_or_error =
      with pid <- GenServer.whereis(ElixirLove.CodeRunner),
           {:ok, result} <- ElixirLove.CodeRunner.execute(pid, command) do
        inspect(result)
      else
        {:error, kind, error, stack} ->
          format_error(kind, error, stack)
      end

    outputs = socket.assigns.outputs ++ ["iex> " <> command] ++ [formatted_result_or_error]

    {:noreply,
     socket
     |> push_event("command", %{text: ""})
     |> assign(outputs: outputs)}
  end

  defp format_error(kind, error, stack) do
    Exception.format(kind, error, stack)
  end
end
