defmodule MentorManager do
  use GenServer

  # Inicia GenServer global
  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})

  # Estado inicial vacío
  def init(state), do: {:ok, state}

  # API global
  def register_mentor(id, meta), do: GenServer.call({:global, __MODULE__}, {:create, id, meta})
  def give_feedback(proj_id, mentor_id, feedback), do: GenServer.call({:global, __MODULE__}, {:fb, proj_id, mentor_id, feedback})
  def get_feedback(proj_id), do: GenServer.call({:global, __MODULE__}, {:get_fb, proj_id})

  # Callbacks
  def handle_call({:create, id, meta}, _from, state) do
    PersistenceETS.insert(:mentors, id, meta)
    {:reply, :ok, state}
  end

  def handle_call({:fb, proj, mentor_id, fb}, _from, state) do
    PersistenceETS.add_feedback(proj, %{mentor: mentor_id, fb: fb, ts: :os.system_time(:millisecond)})
    {:reply, :ok, state}
  end

  def handle_call({:get_fb, proj}, _from, state) do
    {:reply, PersistenceETS.get_feedback(proj), state}
  end
end
