defmodule ChatRoom do
  use GenServer

  # Inicia GenServer global por sala
  def start_link(room), do: GenServer.start_link(__MODULE__, room, name: {:global, {:_chat_room, room}})

  def init(room) do
    ChatPubSub.subscribe(room, self())
    msgs = PersistenceETS.get_messages(room)
    {:ok, %{room: room, messages: msgs}}
  end

  # Envía mensaje a la sala
  def send_msg(room, from, text) do
    msg = %{from: from, text: text, ts: :os.system_time(:millisecond)}
    ChatPubSub.broadcast(room, msg)
  end

  # Maneja mensajes recibidos
  def handle_info({:chat, _room, msg}, state) do
    {:noreply, %{state | messages: [msg | state.messages]}}
  end
end
