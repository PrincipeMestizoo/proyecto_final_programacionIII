Code.require_file("app_supervisor.exs")
Code.require_file("chat_room.exs")

defmodule ChatNode do
  # Inicializa el chat del nodo
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

  # Interfaz de lectura de mensajes del usuario
  defp loop(room) do
    IO.write("#{Node.self()} » ")

    case IO.gets("") do
      nil -> :ok
      input ->
        input = String.trim(input)

        cond do
          input == ":exit" ->
            IO.puts("Saliendo…")
            :init.stop()

          input == ":nodes" ->
            IO.inspect(Node.list(), label: "Nodos conectados")
            loop(room)

          String.starts_with?(input, ":connect ") ->
            [_, nodo_str] = String.split(input, " ")
            nodo = String.to_atom(nodo_str)
            IO.puts("Conectando a #{inspect(nodo)} …")
            IO.inspect(Node.connect(nodo))
            loop(room)

          true ->
            ChatRoom.send_msg(room, Node.self(), input)
            loop(room)
        end
    end
  end

  # Listener que imprime mensajes recibidos (proceso separado)
  defp listener(room) do
    receive do
      {:chat, ^room, msg} ->
        # Imprime bonito sin interrumpir la línea de escritura
        IO.puts("\n[#{msg.from}] #{msg.text}")
        IO.write("#{Node.self()} » ")
        listener(room)

      _ ->
        listener(room)
    end
  end
end

ChatNode.start()
