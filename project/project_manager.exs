Code.require_file("persistence_ets.exs")

defmodule ProjectManager do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def init(state), do: {:ok, state}

  def create_project(team_id, proj_id, data) do
    GenServer.call(__MODULE__, {:create, team_id, proj_id, data})
  end
  def add_update(proj_id, update) do
    GenServer.call(__MODULE__, {:update, proj_id, update})
  end
  def get_project(proj_id), do: GenServer.call(__MODULE__, {:get, proj_id})

  def handle_call({:create, team_id, pid, data}, _from, state) do
    rec = %{team: team_id, id: pid, data: data, updates: []}
    PersistenceETS.insert(:projects, pid, rec)
    {:reply, {:ok, pid}, state}
  end

  def handle_call({:update, pid, upd}, _from, state) do
    case PersistenceETS.get(:projects, pid) do
      {:ok, p} ->
        new = Map.update!(p, :updates, fn u -> [upd | u] end)
        PersistenceETS.insert(:projects, pid, new)
        {:reply, {:ok, new}, state}
      :error -> {:reply, :error, state}
    end
  end

  def handle_call({:get, pid}, _from, state), do: {:reply, PersistenceETS.get(:projects, pid), state}
end
