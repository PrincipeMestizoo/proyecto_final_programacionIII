Code.require_file("persistence_ets.exs")

defmodule TeamManager do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  def init(state), do: {:ok, state}

  def create_team(id, meta) do
    GenServer.call(__MODULE__, {:create, id, meta})
  end
  def list_teams(), do: GenServer.call(__MODULE__, :list)
  def get_team(id), do: GenServer.call(__MODULE__, {:get, id})
  def add_member(team_id, user) do
    GenServer.call(__MODULE__, {:add_member, team_id, user})
  end

  def handle_call({:create, id, meta}, _from, state) do
    PersistenceETS.insert(:teams, id, Map.put(meta, :members, []))
    {:reply, {:ok, id}, state}
  end
  def handle_call(:list, _from, state) do
    {:reply, PersistenceETS.all(:teams), state}
  end
  def handle_call({:get, id}, _from, state) do
    {:reply, PersistenceETS.get(:teams, id), state}
  end
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
