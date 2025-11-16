Code.require_file(Path.expand("./team_manager.exs"))
Code.require_file(Path.expand("./project_manager.exs"))
Code.require_file(Path.expand("./mentor_manager.exs"))
Code.require_file(Path.expand("./chat_pubsub.exs"))
Code.require_file(Path.expand("./chat_room.exs"))
Code.require_file(Path.expand("./persistence_ets.exs"))

defmodule AppSupervisor do
  use Supervisor

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

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

{:ok, _} = AppSupervisor.start_link(nil)
