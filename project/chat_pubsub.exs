defmodule ChatPubSub do
  use GenServer

  # Inicia el GenServer y crea un Registry para manejar subscripciones por sala.
  # El registry permite que cada sala tenga una lista de procesos suscritos.
  def start_link(_) do
    Registry.start_link(keys: :unique, name: ChatRegistry)
    GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})
  end

  # Estado inicial vacío; no se utiliza, pero es necesario para el GenServer.
  def init(state), do: {:ok, state}

  # Registra un proceso en una sala específica dentro del Registry.
  # Cada proceso queda asociado a la clave 'room'.
  def subscribe(room, _pid) do
    Registry.register(ChatRegistry, room, [])
    :ok
  end

  # Envía un mensaje a todos los procesos registrados en la sala indicada.
  # Primero guarda el mensaje en ETS mediante PersistenceETS.
  # Luego envía {:chat, room, msg} a cada proceso suscrito.
  def broadcast(room, msg) do
    PersistenceETS.add_message(room, msg)

    for {pid, _} <- Registry.lookup(ChatRegistry, room) do
      send(pid, {:chat, room, msg})
    end

    :ok
  end
end
