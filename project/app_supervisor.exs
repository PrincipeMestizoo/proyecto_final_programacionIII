# ====================================================================
# CARGA DE MÓDULOS DEL SISTEMA (equipos, proyectos, mentores, chat…)
# ====================================================================

Code.require_file("persistence_ets.exs")
Code.require_file("team_manager.exs")
Code.require_file("project_manager.exs")
Code.require_file("mentor_manager.exs")
Code.require_file("chat_pubsub.exs")
Code.require_file("chat_room.exs")

# ====================================================================
# SUPERVISOR PRINCIPAL
# ====================================================================

defmodule AppSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: {:global, AppSupervisor})
  end

  def init(:ok) do
    children = [
      %{id: TeamManager,    start: {TeamManager, :start_link, [[]]}},
      %{id: ProjectManager, start: {ProjectManager, :start_link, [[]]}},
      %{id: ChatPubSub,     start: {ChatPubSub, :start_link, [[]]}},
      %{id: MentorManager,  start: {MentorManager, :start_link, [[]]}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

# ====================================================================
# ARRANQUE AUTOMÁTICO SOLO SI NO EXISTE OTRO SUPERVISOR GLOBAL
# ====================================================================

case :global.whereis_name(AppSupervisor) do
  :undefined ->
    IO.puts("\n>>> Arrancando supervisor principal en este nodo…\n")
    {:ok, _} = AppSupervisor.start_link(nil)

  pid when is_pid(pid) ->
    IO.puts("\n>>> Supervisor ya está corriendo en otro nodo: #{inspect(pid)}\n")
end
