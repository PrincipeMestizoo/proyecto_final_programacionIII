# Carga el supervisor para asegurar que TeamManager, ProjectManager, ChatPubSub, etc. estén activos.
Code.require_file("app_supervisor.exs")

# Carga la lógica de las salas de chat.
Code.require_file("chat_room.exs")

defmodule ChatNode do
  # Inicia un nodo de chat en la sala indicada (por defecto, "general").
  # Activa trap_exit para manejar salidas seguras.
  # Crea un proceso listener que imprime mensajes recibidos.
  # Muestra comandos disponibles y abre el loop principal.
  def start(room \\ "general") do
    Process.flag(:trap_exit, true)
    ChatRoom.start_link(room)
    spawn(fn -> listener(room) end)

    IO.puts("\n=== Chat iniciado en sala '#{room}' ===")
    IO.puts("Comandos:")
    IO.puts("  :nodes      -> mostrar nodos conectados")
    IO.puts("  :connect n  -> conectar con nodo n")
    IO.puts("  :exit       -> salir")
    IO.puts("-------------------------------------------\n")

    loop(room)
  end

  # Loop principal de entrada de usuario.
  # Captura comandos, gestiona conexiones entre nodos y envía mensajes a ChatRoom.
  defp loop(room) do
    IO.write("#{Node.self()} » ")

    case IO.gets("") do
      nil -> :ok

      input ->
        input = String.trim(input)

        cond do
          # Comando para salir del chat y cerrar el nodo.
          input == ":exit" ->
            IO.puts("Saliendo…")
            :init.stop()

          # Lista los nodos conectados al nodo actual.
          input == ":nodes" ->
            IO.inspect(Node.list(), label: "Nodos conectados")
            loop(room)

          # Permite conectar este nodo con otro nodo distribuido.
          String.starts_with?(input, ":connect ") ->
            [_, nodo_str] = String.split(input, " ")
            nodo = String.to_atom(nodo_str)
            IO.puts("Conectando a #{inspect(nodo)} …")
            IO.inspect(Node.connect(nodo))
            loop(room)

          # Cualquier texto se considera un mensaje normal.
          true ->
            ChatRoom.send_msg(room, Node.self(), input)
            loop(room)
        end
    end
  end

  # Listener en proceso separado.
  # Escucha mensajes enviados a la sala y los imprime sin interrumpir el prompt.
  defp listener(room) do
    receive do
      {:chat, ^room, msg} ->
        IO.puts("\n[#{msg.from}] #{msg.text}")
        IO.write("#{Node.self()} » ")
        listener(room)

      _ ->
        listener(room)
    end
  end
end

# Inicia el nodo de chat al cargar el archivo.
ChatNode.start()
