# Carga la capa de persistencia basada en ETS para almacenar equipos y miembros.
Code.require_file("persistence_ets.exs")

defmodule TeamManager do
  use GenServer

  # Inicia el GenServer encargado de manejar la gestión de equipos.
  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})

  # Estado inicial vacío; todos los datos se almacenan en ETS.
  def init(state), do: {:ok, state}

  # Crea un equipo, recibiendo un ID y un mapa con los datos del equipo.
  # El mapa meta debe contener información general (ej: nombre del equipo).
  def create_team(id, meta) do
    GenServer.call(__MODULE__, {:create, id, meta})
  end

  # Devuelve una lista con todos los equipos registrados.
  def list_teams(), do: GenServer.call(__MODULE__, :list)

  # Obtiene un equipo específico por su ID.
  def get_team(id), do: GenServer.call(__MODULE__, {:get, id})

  # Agrega un usuario como miembro del equipo indicado.
  # user es un mapa con la información del usuario.
  def add_member(team_id, user) do
    GenServer.call(__MODULE__, {:add_member, team_id, user})
  end


  # Maneja la creación del equipo y lo almacena en ETS con lista de miembros vacía.
  def handle_call({:create, id, meta}, _from, state) do
    PersistenceETS.insert(:teams, id, Map.put(meta, :members, []))
    {:reply, {:ok, id}, state}
  end

  # Maneja la consulta de todos los equipos.
  def handle_call(:list, _from, state) do
    {:reply, PersistenceETS.all(:teams), state}
  end

  # Maneja obtener un equipo específico por ID.
  def handle_call({:get, id}, _from, state) do
    {:reply, PersistenceETS.get(:teams, id), state}
  end

  # Maneja la lógica de agregar un miembro a un equipo existente.
  # Si el equipo existe, se actualiza el mapa con el nuevo usuario.
  def handle_call({:add_member, id, user}, _from, state) do
    case PersistenceETS.get(:teams, id) do
      {:ok, t} ->
        new = Map.update!(t, :members, fn ms -> [user | ms] end)
        PersistenceETS.insert(:teams, id, new)
        {:reply, {:ok, new}, state}

      :error ->
        {:reply, :error, state}
    end
  end
end
