Code.require_file("./team_manager.exs")
Code.require_file("./project_manager.exs")
Code.require_file("./mentor_manager.exs")
Code.require_file("./chat_pubsub.exs")
Code.require_file("./chat_room.exs")
Code.require_file("./persistence_ets.exs")

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
