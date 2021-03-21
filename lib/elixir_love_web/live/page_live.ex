defmodule ElixirLoveWeb.PageLive do
  use ElixirLoveWeb, :live_view

  alias ElixirLove.CodeSession

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    topic_name = "code_session_events"
    ElixirLove.PubSub |> Phoenix.PubSub.subscribe(topic_name)

    {:ok,
     socket
     |> assign(
       input_value: "",
       current_session_id: nil,
       session_ids: CodeSession.session_ids(),
       logs: []
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("set_input_value", %{"command" => %{"text" => command}}, socket) do
    {:noreply, socket |> assign(:input_value, command)}
  end

  @impl Phoenix.LiveView
  def handle_event("execute", %{"command" => %{"text" => command}}, socket) do
    CodeSession.execute(socket.assigns.current_session_id, command)

    new_socket =
      socket
      |> push_event("command", %{text: ""})

    {:noreply, new_socket}
  end

  @impl Phoenix.LiveView
  def handle_event("start_session", %{}, socket) do
    {:ok, session_id} = CodeSession.start_session()

    socket =
      socket
      |> assign(
        current_session_id: session_id,
        session_ids: CodeSession.session_ids()
      )

    {:noreply, socket}
  end

  @impl Phoenix.LiveView
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

  @impl Phoenix.LiveView
  def handle_event("switch_session", %{"session-id" => current_session_id}, socket) do
    {session_id, ""} = Integer.parse(current_session_id)

    {:noreply,
     socket
     |> assign(current_session_id: session_id, logs: CodeSession.get_logs(session_id))}
  end

  @impl Phoenix.LiveView
  def handle_info(
        {:put_log, session_id, log},
        %{assigns: %{current_session_id: current_session_id}} = socket
      )
      when session_id == current_session_id do
    {:noreply,
     socket
     |> assign(logs: socket.assigns.logs ++ [log])}
  end

  @impl Phoenix.LiveView
  def handle_info({:put_log, _session_id, _log}, socket) do
    {:noreply, socket}
  end

  def handle_info({:session_ids, session_ids}, socket) do
    if Enum.member?(session_ids, socket.assigns.current_session_id) do
      {:noreply, socket |> assign(session_ids: session_ids)}
    else
      {:noreply, socket |> assign(session_ids: session_ids, current_session_id: nil)}
    end
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
