defmodule ElixirLove.CodeRunner do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def execute(runner, code) do
    GenServer.call(runner, {:execute, code})
  end

  # Callbacks

  @impl GenServer
  def init(_) do
    {:ok, %{bindings: [], env: init_env()}}
  end

  @impl GenServer
  def handle_call({:execute, code}, _from, state) do
    try do
      {result, bindings, env} = do_execute(code, state.bindings, state.env)
      new_state = %{state | bindings: bindings, env: env}
      {:reply, {:ok, result}, new_state}
    catch
      kind, error ->
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
end
