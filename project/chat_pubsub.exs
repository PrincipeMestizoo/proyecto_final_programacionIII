defmodule ChatPubSub do
  use GenServer

  # Inicia Registry y GenServer global
  def start_link(_) do
    Registry.start_link(keys: :unique, name: ChatRegistry)
    GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})
  end

  def init(state), do: {:ok, state}

  # Suscribe un proceso a una sala
  def subscribe(room, _pid) do
    Registry.register(ChatRegistry, room, [])
    :ok
  end

  # Envía un mensaje a todos los suscritos y lo guarda en ETS
  def broadcast(room, msg) do
    PersistenceETS.add_message(room, msg)
    for {pid, _} <- Registry.lookup(ChatRegistry, room), do: send(pid, {:chat, room, msg})
    :ok
  end
end
