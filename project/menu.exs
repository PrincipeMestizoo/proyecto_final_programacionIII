Code.require_file("team_manager.exs")
Code.require_file("project_manager.exs")
Code.require_file("mentor_manager.exs")
Code.require_file("chat_pubsub.exs")
Code.require_file("chat_room.exs")
Code.require_file("persistence_ets.exs")


# arranque

defmodule AutoStart do
  def ensure_supervisor_running do
    tm = Process.whereis(TeamManager)
    pm = Process.whereis(ProjectManager)
    mm = Process.whereis(MentorManager)
    pub = Process.whereis(ChatPubSub)

    if tm == nil or pm == nil or mm == nil or pub == nil do
      IO.puts("\n>>> No hay supervisor activo. Arrancando AppSupervisor...\n")
      Code.require_file("app_supervisor.exs")
    else
      :ok
    end
  end
end

# menu para las funcionalidades

defmodule Menu do
  def start do
    AutoStart.ensure_supervisor_running()
    loop()
  end



  defp loop do
    IO.puts("""
    -----------------------------
            MENÚ PRINCIPAL

    ---Equipos---
    1. Crear equipo
    2. Listar equipos
    3. Añadir miembro al equipo

    ---Proyectos---
    4. Crear proyecto completo
    5. Listar proyectos
    6. Enviar mensaje a sala
    7. Ver mensajes de una sala

    ---Mentoria---
    8. Registrar mentor
    9. Enviar feedback de mentor
    10. Ver feedback de un proyecto

    0. Salir

    -----------------------------
    """)

    opcion =
      IO.gets("Seleccione una opción: ")
      |> String.trim()

    case opcion do
      "1" -> crear_equipo()
      "2" -> listar_equipos()
      "3" -> add_miembro()
      "4" -> crear_proyecto()
      "5" -> listar_proyectos()
      "6" -> enviar_msg()
      "7" -> ver_msg()

      "8" -> registrar_mentor()
      "9" -> enviar_feedback()
      "10" -> ver_feedback()

      "0" -> salir()
      _ ->
        IO.puts("Opción inválida.")
        loop()
    end
  end

  # equipos
  defp crear_equipo do
    id = IO.gets("ID del equipo: ") |> String.trim()
    nombre = IO.gets("Nombre del equipo: ") |> String.trim()
    TeamManager.create_team(id, %{name: nombre})
    IO.puts("Equipo creado correctamente!")
    loop()
  end

  defp listar_equipos do
    IO.inspect(TeamManager.list_teams(), label: "Equipos registrados")
    loop()
  end

  defp add_miembro do
    id = IO.gets("ID equipo: ") |> String.trim()
    uid = IO.gets("ID usuario: ") |> String.trim()
    nombre = IO.gets("Nombre usuario: ") |> String.trim()
    TeamManager.add_member(id, %{id: uid, name: nombre})
    IO.puts("Miembro añadido!")
    loop()
  end

  # proyectos
  defp crear_proyecto do
    tid = IO.gets("ID equipo dueño: ") |> String.trim()
    pid = IO.gets("ID proyecto: ") |> String.trim()
    titulo = IO.gets("Título del proyecto: ") |> String.trim()
    desc = IO.gets("Descripción: ") |> String.trim()
    cat = IO.gets("Categoría: ") |> String.trim()

    ProjectManager.create_project(tid, pid, titulo, desc, cat)
    IO.puts("Proyecto creado!")
    loop()
  end

  defp listar_proyectos do
    IO.inspect(ProjectManager.list_projects(), label: "Proyectos")
    loop()
  end

  # mensajeria
  defp enviar_msg do
    sala = IO.gets("Sala: ") |> String.trim()
    user = IO.gets("Usuario: ") |> String.trim()
    msg  = IO.gets("Mensaje: ") |> String.trim()

    ChatRoom.start_link(sala)
    ChatRoom.send_msg(sala, user, msg)

    IO.puts("Mensaje enviado!")
    loop()
  end

  defp ver_msg do
    sala = IO.gets("Sala: ") |> String.trim()
    IO.inspect(PersistenceETS.get_messages(sala), label: "Mensajes en sala")
    loop()
  end

  # mentores
  defp registrar_mentor do
    id = IO.gets("ID del mentor: ") |> String.trim()
    nombre = IO.gets("Nombre del mentor: ") |> String.trim()
    area = IO.gets("Área o especialidad: ") |> String.trim()

    MentorManager.register_mentor(id, %{name: nombre, area: area})
    IO.puts("Mentor registrado correctamente!")
    loop()
  end

  defp enviar_feedback do
    proj = IO.gets("ID del proyecto: ") |> String.trim()
    ment = IO.gets("ID del mentor: ") |> String.trim()
    fb   = IO.gets("Retroalimentación: ") |> String.trim()

    MentorManager.give_feedback(proj, ment, fb)
    IO.puts("Feedback enviado!")
    loop()
  end

  defp ver_feedback do
    proj = IO.gets("ID del proyecto: ") |> String.trim()
    IO.inspect(MentorManager.get_feedback(proj), label: "Feedback del proyecto")
    loop()
  end

  # salida
  defp salir do
    IO.puts("Saliendo del sistema… Adiós!")
    System.halt(0)
  end
end
