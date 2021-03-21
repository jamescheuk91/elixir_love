defmodule ElixirLove.CodeSession.Supervisor do
  use Supervisor

  def start_link(session_id) do
    Supervisor.start_link(__MODULE__, session_id, name: via_tuple(__MODULE__, session_id))
  end

  def init(session_id) do
    children = [
      {ElixirLove.CodeSession.Log, [name: via_tuple(ElixirLove.CodeSession.Log, session_id)]},
      {ElixirLove.CodeSession.CodeRunner,
       [session_id, name: via_tuple(ElixirLove.CodeSession.CodeRunner, session_id)]}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  defp via_tuple(module, session_id) do
    {:via, Registry, {ElixirLove.CodeSession.Registry, {module, session_id}}}
  end
end
