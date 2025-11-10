Code.require_file("app_supervisor.exs")
Code.require_file("chat_room.exs")

defmodule ChatNode do
  def start(room \\ "general") do
    ChatRoom.start_link(room)
    loop(room)
  end

  defp loop(room) do
    IO.write("#{Node.self()} > ")
    case IO.gets("") |> String.trim() do
      ":exit" -> IO.puts("Saliendo..."); :ok
      ":nodes" -> IO.inspect(Node.list()); loop(room)
      msg ->
        ChatRoom.send_msg(room, Node.self(), msg)
        loop(room)
    end
  end
end

ChatNode.start()
