defmodule ElixirLove.CodeSession.CodeRunner do
  use GenServer

  alias ElixirLove.CodeSession

  def start_link([session_id, name: name]) do
    GenServer.start_link(__MODULE__, session_id, name: name)
  end

  def execute(runner, code) do
    GenServer.call(runner, {:execute, code})
  end

  # Callbacks

  @impl GenServer
  def init(session_id) do
    {:ok, %{session_id: session_id, bindings: [], env: init_env()}}
  end

  @impl GenServer
  def handle_call({:execute, code}, _from, state) do
    try do
      log(state.session_id, {:input, code})
      {result, bindings, env} = do_execute(code, state.bindings, state.env)
      log(state.session_id, {:result, result})
      new_state = %{state | bindings: bindings, env: env}
      {:reply, [{:input, code}, {:result, result}], new_state}
    catch
      kind, error ->
        log(state.session_id, {:error, kind, error, __STACKTRACE__})

        {:reply, {:error, kind, error, __STACKTRACE__}, state}
    end
  end

  defp init_env() do
    :elixir.env_for_eval(file: "elixir_love")
  end

  defp do_execute(code, bindings, env) do
    ast = Code.string_to_quoted!(code)
    :elixir.eval_forms(ast, bindings, env)
  end

  defp log(session_id, value) do
    topic_name = "code_session_events"

    ElixirLove.PubSub
    |> Phoenix.PubSub.broadcast(topic_name, {:put_log, session_id, value})

    CodeSession.Log
    |> via_tuple(session_id)
    |> CodeSession.Log.put_log(value)
  end

  defp via_tuple(module, session_id) do
    {:via, Registry, {ElixirLove.CodeSession.Registry, {module, session_id}}}
  end
end
