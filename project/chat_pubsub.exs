defmodule ChatPubSub do
  use GenServer

  # Inicia el GenServer global
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})
  end

  def init(state), do: {:ok, state}

  # Suscribe un proceso a una sala de chat global
  def subscribe(room, pid \\ self()) do
    :ok = :pg.join(room, pid)   # Une el PID al grupo de la sala
    :ok
  end

  # Envía un mensaje a todos los procesos suscritos globalmente
  def broadcast(room, msg) do
    PersistenceETS.add_message(room, msg)

    # Obtiene todos los miembros del grupo distribuido y envía el mensaje
    for pid <- :pg.get_members(room), do: send(pid, {:chat, room, msg})

    :ok
  end
end
