# Carga el sistema de publicación/suscripción y la persistencia ETS.
Code.require_file("chat_pubsub.exs")
Code.require_file("persistence_ets.exs")

defmodule ChatRoom do
  use GenServer

  # Inicia una sala de chat usando un nombre único manejado por Registry.
  # via_tuple(room) asegura que solo exista un proceso por sala.
  def start_link(room), do: GenServer.start_link(__MODULE__, room, name: via_tuple(room))

  # Genera la tupla utilizada por Registry para identificar la sala.
  def via_tuple(room), do: {:via, Registry, {ChatRegistry, room}}

  # Inicializa la sala cargando los mensajes previos desde ETS
  # y registrando el proceso como suscriptor en ChatPubSub.
  def init(room) do
    ChatPubSub.subscribe(room, self())
    msgs = PersistenceETS.get_messages(room)
    {:ok, %{room: room, messages: msgs}}
  end

  # Envía un mensaje a la sala.
  # Crea un map con el remitente, texto y timestamp.
  # El mensaje se publica a todos los suscriptores mediante ChatPubSub.
  def send_msg(room, from, text) do
    msg = %{from: from, text: text, ts: :os.system_time(:millisecond)}
    ChatPubSub.broadcast(room, msg)
  end

  # Maneja mensajes recibidos desde ChatPubSub.
  # Cuando llega {:chat, room, msg}, se agrega al estado interno.
  def handle_info({:chat, _room, msg}, state) do
    {:noreply, %{state | messages: [msg | state.messages]}}
  end
end
