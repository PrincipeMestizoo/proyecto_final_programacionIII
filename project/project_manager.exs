# Carga la capa de persistencia ETS utilizada para guardar los proyectos.
Code.require_file("persistence_ets.exs")

defmodule ProjectManager do
  use GenServer

  # Inicia el GenServer que administra proyectos.
  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})

  # Estado inicial vacío; se almacena información únicamente en ETS.
  def init(state), do: {:ok, state}

  # Crea un proyecto completo con título, descripción, categoría, equipo dueño y fecha de creación.
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

  # Obtiene un proyecto desde ETS por su ID.
  def get_project(pid), do: GenServer.call(__MODULE__, {:get, pid})

  # Agrega un avance (update) a un proyecto con timestamp de segundos.
  def add_update(pid, msg) do
    GenServer.call(__MODULE__, {:add_update, pid, msg, :os.system_time(:second)})
  end

  # Lista todos los proyectos registrados en ETS.
  def list_projects() do
    GenServer.call(__MODULE__, :list)
  end

  # Consulta proyectos por categoría.
  def by_category(cat) do
    GenServer.call(__MODULE__, {:category, cat})
  end

  # Consulta proyectos por ID de equipo.
  def by_team(team_id) do
    GenServer.call(__MODULE__, {:team, team_id})
  end


  # Maneja la creación del proyecto guardándolo en ETS.
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

  # Maneja la consulta de un proyecto por su ID.
  def handle_call({:get, pid}, _from, state) do
    {:reply, PersistenceETS.get(:projects, pid), state}
  end

  # Maneja la adición de un update, actualiza la lista de avances y vuelve a insertar en ETS.
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

  # Devuelve todos los proyectos almacenados.
  def handle_call(:list, _from, state) do
    {:reply, PersistenceETS.all(:projects), state}
  end

  # Filtra los proyectos por categoría.
  def handle_call({:category, cat}, _from, state) do
    result =
      PersistenceETS.all(:projects)
      |> Enum.filter(fn {_k, p} -> p.category == cat end)

    {:reply, result, state}
  end

  # Filtra los proyectos por equipo propietario.
  def handle_call({:team, tid}, _from, state) do
    result =
      PersistenceETS.all(:projects)
      |> Enum.filter(fn {_k, p} -> p.team == tid end)

    {:reply, result, state}
  end
end
