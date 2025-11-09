defmodule ChatPubSub do
  use GenServer

  def start_link(_) do
    Registry.start_link(keys: :unique, name: ChatRegistry)
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state), do: {:ok, state}
  def subscribe(room, _pid) do
    Registry.register(ChatRegistry, room, [])
    :ok
  end
  def broadcast(room, msg) do
    PersistenceETS.add_message(room, msg)
    for {pid, _} <- Registry.lookup(ChatRegistry, room) do
      send(pid, {:chat, room, msg})
    end
    :ok
  end
end
