Code.require_file("persistence_ets.exs")

defmodule ProjectManager do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def init(state), do: {:ok, state}

  # Crear proyecto COMPLETO
  def create_project(team_id, proj_id, title, desc, category) do
    GenServer.call(__MODULE__, {:create,
      team_id,
      proj_id,
      title,
      desc,
      category,
      :os.system_time(:second)
    })
  end

  # Obtener proyecto por ID
  def get_project(pid), do: GenServer.call(__MODULE__, {:get, pid})

  # Actualizar avance
  def add_update(pid, msg) do
    GenServer.call(__MODULE__, {:add_update, pid, msg, :os.system_time(:second)})
  end

  # Consultar todos
  def list_projects() do
    GenServer.call(__MODULE__, :list)
  end

  # Consultar por categoría
  def by_category(cat) do
    GenServer.call(__MODULE__, {:category, cat})
  end

  # Consultar por equipo
  def by_team(team_id) do
    GenServer.call(__MODULE__, {:team, team_id})
  end


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

  def handle_call({:get, pid}, _from, state) do
    {:reply, PersistenceETS.get(:projects, pid), state}
  end

  def handle_call({:add_update, pid, msg, ts}, _from, state) do
    case PersistenceETS.get(:projects, pid) do
      {:ok, p} ->
        upd = %{msg: msg, ts: ts}
        updated = Map.update!(p, :updates, fn u -> [upd | u] end)

        PersistenceETS.insert(:projects, pid, updated)
        {:reply, {:ok, updated}, state}

      :error ->
        {:reply, :error, state}
    end
  end

  def handle_call(:list, _from, state) do
    {:reply, PersistenceETS.all(:projects), state}
  end

  def handle_call({:category, cat}, _from, state) do
    result =
      PersistenceETS.all(:projects)
      |> Enum.filter(fn {_k, p} -> p.category == cat end)

    {:reply, result, state}
  end

  def handle_call({:team, tid}, _from, state) do
    result =
      PersistenceETS.all(:projects)
      |> Enum.filter(fn {_k, p} -> p.team == tid end)

    {:reply, result, state}
  end
end
