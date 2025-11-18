defmodule ChatRoom do
  use GenServer

  # Inicia la sala global
  def start_link(room) do
    GenServer.start_link(__MODULE__, room, name: {:global, {:_chat_room, room}})
  end

  def init(room) do
    # Suscribe este proceso al grupo distribuido
    ChatPubSub.subscribe(room, self())

    # Trae mensajes previos de ETS
    msgs = PersistenceETS.get_messages(room)
    {:ok, %{room: room, messages: msgs}}
  end

  # Envía un mensaje a la sala
  def send_msg(room, from, text) do
    msg = %{from: from, text: text, ts: :os.system_time(:millisecond)}
    ChatPubSub.broadcast(room, msg)
  end

  # Recibe mensajes de otros procesos
  def handle_info({:chat, _room, msg}, state) do
    {:noreply, %{state | messages: [msg | state.messages]}}
  end
end
