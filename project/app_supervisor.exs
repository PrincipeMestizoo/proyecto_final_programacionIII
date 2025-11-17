# Carga de los módulos del sistema: equipos, proyectos, mentores, chat y persistencia ETS.
Code.require_file(Path.expand("./team_manager.exs"))
Code.require_file(Path.expand("./project_manager.exs"))
Code.require_file(Path.expand("./mentor_manager.exs"))
Code.require_file(Path.expand("./chat_pubsub.exs"))
Code.require_file(Path.expand("./chat_room.exs"))
Code.require_file(Path.expand("./persistence_ets.exs"))

defmodule AppSupervisor do
  use Supervisor

  # Inicia el supervisor principal y lo registra con un nombre global.
  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Configura los procesos del sistema.
  # Incluye los manejadores de equipos, proyectos, mentores y chat.
  # Estrategia :one_for_one: si un proceso falla, solo ese proceso se reinicia.
  def init(:ok) do
    children = [
      {TeamManager, []},
      {ProjectManager, []},
      {ChatPubSub, []},
      {MentorManager, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end

# Arranque automático del supervisor al cargar este archivo.
{:ok, _} = AppSupervisor.start_link(nil)
