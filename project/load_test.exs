Code.require_file("app_supervisor.exs")
Code.require_file("chat_room.exs")
Code.require_file("persistence_ets.exs")

ChatRoom.start_link("room-load")

1..200
|> Enum.map(fn i ->
  Task.async(fn ->
    ChatRoom.send_msg("room-load", "u#{i}", "msg #{i}")
  end)
end)
|> Enum.map(&Task.await(&1, :infinity))

msgs = PersistenceETS.get_messages("room-load")
IO.puts("mensajes enviados: #{length(msgs)}")
