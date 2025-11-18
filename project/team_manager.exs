defmodule TeamManager do
  use GenServer

  # Inicia el GenServer global
  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})

  # Estado inicial vacío
  def init(state), do: {:ok, state}

  # API global
  def create_team(id, meta), do: GenServer.call({:global, __MODULE__}, {:create, id, meta})
  def list_teams(), do: GenServer.call({:global, __MODULE__}, :list)
  def get_team(id), do: GenServer.call({:global, __MODULE__}, {:get, id})
  def add_member(team_id, user), do: GenServer.call({:global, __MODULE__}, {:add_member, team_id, user})

  # Callbacks
  def handle_call({:create, id, meta}, _from, state) do
    PersistenceETS.insert(:teams, id, Map.put(meta, :members, []))
    {:reply, {:ok, id}, state}
  end

  def handle_call(:list, _from, state), do: {:reply, PersistenceETS.all(:teams), state}

  def handle_call({:get, id}, _from, state), do: {:reply, PersistenceETS.get(:teams, id), state}

  def handle_call({:add_member, id, user}, _from, state) do
    case PersistenceETS.get(:teams, id) do
      {:ok, t} ->
        new = Map.update!(t, :members, fn ms -> [user | ms] end)
        PersistenceETS.insert(:teams, id, new)
        {:reply, {:ok, new}, state}
      :error -> {:reply, :error, state}
    end
  end
end
