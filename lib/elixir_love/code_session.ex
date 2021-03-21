defmodule ElixirLove.CodeSession do
  alias ElixirLove.CodeSession

  def start_session() do
    with session_id <- CodeSession.Counter.next_id(),
         spec <-
           %{
             id: :ignored,
             start: {CodeSession.Supervisor, :start_link, [session_id]},
             restart: :transient,
             type: :supervisor
           },
         {:ok, _pid} <- DynamicSupervisor.start_child(CodeSession.DynamicSupervisor, spec) do
      {:ok, session_id}
    end
  end

  def stop_session(session_id) when is_integer(session_id) do
    with [{supervisor_pid, _}] <-
           Registry.lookup(CodeSession.Registry, {CodeSession.Supervisor, session_id}) do
      Supervisor.stop(supervisor_pid, :normal)
    else
      [] ->
        {:error, :not_found}

      err ->
        err
    end
  end

  def session_ids() do
    CodeSession.Registry
    |> Registry.select([{{{CodeSession.Supervisor, :"$1"}, :"$2", :"$3"}, [], [{{:"$1"}}]}])
    |> Enum.map(&elem(&1, 0))
    |> Enum.sort()
  end

  def execute(session_id, code) when is_integer(session_id) do
    CodeSession.CodeRunner
    |> via_tuple(session_id)
    |> GenServer.call({:execute, code})
  end

  def get_logs(session_id) when is_integer(session_id) do
    CodeSession.Log
    |> via_tuple(session_id)
    |> CodeSession.Log.get_logs()
  end

  defp via_tuple(module, session_id) when is_integer(session_id) do
    {:via, Registry, {CodeSession.Registry, {module, session_id}}}
  end
end
