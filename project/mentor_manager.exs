Code.require_file("persistence_ets.exs")

defmodule MentorManager do
  use GenServer
  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def init(state), do: {:ok, state}

  def register_mentor(id, meta), do: GenServer.call(__MODULE__, {:create, id, meta})
  def give_feedback(proj_id, mentor_id, feedback), do: GenServer.call(__MODULE__, {:fb, proj_id, mentor_id, feedback})
  def get_feedback(proj_id), do: GenServer.call(__MODULE__, {:get_fb, proj_id})

  def handle_call({:create, id, meta}, _from, state) do
    PersistenceETS.insert(:teams, {:mentor, id}, meta)
    {:reply, :ok, state}
  end
  def handle_call({:fb, proj, m, fb}, _from, state) do
    PersistenceETS.add_message({:feedback, proj}, %{mentor: m, fb: fb, ts: :os.system_time(:millisecond)})
    {:reply, :ok, state}
  end
  def handle_call({:get_fb, proj}, _from, state) do
    {:reply, PersistenceETS.get_messages({:feedback, proj}), state}
  end
end
