defmodule ProjectManager do
  use GenServer

  # Inicia GenServer global
  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})

  # Estado inicial vacío
  def init(state), do: {:ok, state}

  # API global
  def create_project(team_id, proj_id, title, desc, category) do
    GenServer.call({:global, __MODULE__}, {:create, team_id, proj_id, title, desc, category, :os.system_time(:second)})
  end

  def get_project(pid), do: GenServer.call({:global, __MODULE__}, {:get, pid})
  def add_update(pid, msg), do: GenServer.call({:global, __MODULE__}, {:add_update, pid, msg, :os.system_time(:second)})
  def list_projects(), do: GenServer.call({:global, __MODULE__}, :list)
  def by_category(cat), do: GenServer.call({:global, __MODULE__}, {:category, cat})
  def by_team(team_id), do: GenServer.call({:global, __MODULE__}, {:team, team_id})

  # Callbacks
  def handle_call({:create, team_id, pid, title, desc, cat, created}, _from, state) do
    rec = %{
      id: pid,
      title: title,
      description: desc,
      category: cat,
      team: team_id,
      created_at: created,
      updates: []
    }
    PersistenceETS.insert(:projects, pid, rec)
    {:reply, {:ok, pid}, state}
  end

  def handle_call({:get, pid}, _from, state), do: {:reply, PersistenceETS.get(:projects, pid), state}

  def handle_call({:add_update, pid, msg, ts}, _from, state) do
    case PersistenceETS.get(:projects, pid) do
      {:ok, p} ->
        upd = %{msg: msg, ts: ts}
        updated = Map.update!(p, :updates, fn u -> [upd | u] end)
        PersistenceETS.insert(:projects, pid, updated)
        {:reply, {:ok, updated}, state}
      :error -> {:reply, :error, state}
    end
  end

  def handle_call(:list, _from, state), do: {:reply, PersistenceETS.all(:projects), state}

  def handle_call({:category, cat}, _from, state) do
    result = PersistenceETS.all(:projects) |> Enum.filter(fn {_k, p} -> p.category == cat end)
    {:reply, result, state}
  end

  def handle_call({:team, tid}, _from, state) do
    result = PersistenceETS.all(:projects) |> Enum.filter(fn {_k, p} -> p.team == tid end)
    {:reply, result, state}
  end
end
