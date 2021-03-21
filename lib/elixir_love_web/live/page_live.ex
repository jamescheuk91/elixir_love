defmodule ElixirLoveWeb.PageLive do
  use ElixirLoveWeb, :live_view

  alias ElixirLove.CodeSession

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       current_session_id: nil,
       session_ids: CodeSession.session_ids(),
       logs: []
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("execute", %{"command" => %{"text" => command}}, socket) do
    logs = CodeSession.execute(socket.assigns.current_session_id, command)

    {:noreply,
     socket
     |> push_event("command", %{text: ""})
     |> assign(logs: socket.assigns.logs ++ logs)}
  end

  def handle_event("start_session", %{}, socket) do
    {:ok, session_id} = CodeSession.start_session()
    socket = socket
    |> assign(
      current_session_id: session_id,
      session_ids: CodeSession.session_ids()
      )
    {:noreply, socket}
  end

  def handle_event("stop_session", %{"session-id" => session_id}, socket) do
    {session_id, ""} = Integer.parse(session_id)
    CodeSession.stop_session(session_id)

    if socket.assigns.current_session_id == session_id do
      {:noreply,
       socket
       |> assign(
         current_session_id: nil,
         logs: [],
         session_ids: CodeSession.session_ids()
       )}
    else
      {:noreply, socket |> assign(session_ids: CodeSession.session_ids())}
    end
  end

  def handle_event("switch_session", %{"session-id" => sid}, socket) do
    {session_id, ""} = Integer.parse(sid)

    {:noreply,
     socket
     |> assign(current_session_id: session_id, logs: CodeSession.get_logs(session_id))}
  end

  defp format({:error, kind, error, stack}) do
    Exception.format(kind, error, stack)
  end

  defp format({:input, code}) do
    code
  end

  defp format({:result, value}) do
    inspect(value)
  end
end
