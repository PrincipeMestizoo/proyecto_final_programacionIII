Code.require_file("app_supervisor.exs")

defmodule Menu do
  def start do
    loop()
  end

  defp loop do
    IO.puts("""
    ==== MENÚ DEL SISTEMA ====
    1. Crear equipo
    2. Ver equipos
    3. Crear proyecto
    4. Ver proyecto
    5. Registrar mentor
    6. Enviar feedback
    7. Ver feedback
    8. Enviar mensaje al chat
    9. Ver mensajes del chat
    0. Salir
    """)

    case IO.gets("Opción: ") |> String.trim() do
      "1" -> crear_equipo()
      "2" -> ver_equipos()
      "3" -> crear_proyecto()
      "4" -> ver_proyecto()
      "5" -> registrar_mentor()
      "6" -> enviar_feedback()
      "7" -> ver_feedback()
      "8" -> enviar_mensaje_chat()
      "9" -> ver_mensajes_chat()
      "0" -> System.halt(0)
      _ -> IO.puts("Opción inválida")
    end

    loop()
  end

  defp crear_equipo do
    id = IO.gets("ID del equipo: ") |> String.trim()
    nombre = IO.gets("Nombre del equipo: ") |> String.trim()
    TeamManager.create_team(id, %{name: nombre, members: []})
    IO.puts("Equipo creado!\n")
  end

  defp ver_equipos do
    IO.inspect(TeamManager.list_teams(), label: "Equipos")
  end

  defp crear_proyecto do
    team = IO.gets("Equipo: ") |> String.trim()
    id = IO.gets("ID del proyecto: ") |> String.trim()
    titulo = IO.gets("Título: ") |> String.trim()
    ProjectManager.create_project(team, id, %{title: titulo})
  end

  defp ver_proyecto do
    id = IO.gets("ID del proyecto: ") |> String.trim()
    IO.inspect(ProjectManager.get_project(id), label: "Proyecto")
  end

  defp registrar_mentor do
    id = IO.gets("ID mentor: ") |> String.trim()
    nombre = IO.gets("Nombre: ") |> String.trim()
    MentorManager.register_mentor(id, %{name: nombre})
  end

  defp enviar_feedback do
    p = IO.gets("Proyecto: ") |> String.trim()
    m = IO.gets("Mentor: ") |> String.trim()
    msg = IO.gets("Feedback: ") |> String.trim()
    MentorManager.give_feedback(p, m, msg)
  end

  defp ver_feedback do
    p = IO.gets("Proyecto: ") |> String.trim()
    IO.inspect(MentorManager.get_feedback(p), label: "Feedback")
  end

  defp enviar_mensaje_chat do
    sala = IO.gets("Sala: ") |> String.trim()
    usuario = IO.gets("Usuario: ") |> String.trim()
    msg = IO.gets("Mensaje: ") |> String.trim()
    ChatPubSub.broadcast(sala, {self(), usuario, msg})
  end

  defp ver_mensajes_chat do
    sala = IO.gets("Sala: ") |> String.trim()
    IO.inspect(PersistenceETS.get_messages(sala), label: "Mensajes")
  end
end

Menu.start()
