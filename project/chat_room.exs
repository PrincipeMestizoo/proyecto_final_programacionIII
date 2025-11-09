Code.require_file("chat_pubsub.exs")
Code.require_file("persistence_ets.exs")

defmodule ChatRoom do
  use GenServer

  def start_link(room), do: GenServer.start_link(__MODULE__, room, name: via_tuple(room))
  def via_tuple(room), do: {:via, Registry, {ChatRegistry, room}}

  def init(room) do
    ChatPubSub.subscribe(room, self())
    msgs = PersistenceETS.get_messages(room)
    {:ok, %{room: room, messages: msgs}}
  end

  def send_msg(room, from, text) do
    msg = %{from: from, text: text, ts: :os.system_time(:millisecond)}
    ChatPubSub.broadcast(room, msg)
  end

  def handle_info({:chat, _room, msg}, state) do
    {:noreply, %{state | messages: [msg | state.messages]}}
  end
end
