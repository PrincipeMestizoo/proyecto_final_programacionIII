# Arranque
defmodule AutoStart do
  def ensure_supervisor_running do
    need =
      [
        Process.whereis(TeamManager),
        Process.whereis(ProjectManager),
        Process.whereis(MentorManager),
        Process.whereis(ChatPubSub)
      ]

    if Enum.any?(need, &(&1 == nil)) do
      IO.puts("\n>>> No hay supervisor activo. Arrancando AppSupervisor...\n")
      Code.require_file("app_supervisor.exs")
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
    ============================

            MENÚ PRINCIPAL

    ---Proyectos---
    4. Crear proyecto completo
    5. Listar proyectos
    6. Actualizar avance
    7. Proyectos por categoría
    8. Proyectos por equipo
    9. Ver proyecto por ID

    ---Mensajeria---
    10. Enviar mensaje
    11. Ver mensajes

    0. Salir

    ============================
    """)

    opcion = IO.gets("Opción: ") |> String.trim()

    case opcion do
      "1" -> crear_equipo()
      "2" -> listar_equipos()
      "3" -> add_miembro()
      "4" -> crear_proyecto()
      "5" -> listar_proyectos()
      "6" -> actualizar_avance()
      "7" -> proyectos_categoria()
      "8" -> proyectos_equipo()
      "9" -> proyecto_id()
      "10" -> enviar_mensaje()
      "11" -> ver_mensajes()
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
    IO.puts("Equipo creado!")
    loop()
  end

  defp listar_equipos do
    IO.inspect(TeamManager.list_teams(), label: "Equipos registrados")
    loop()
  end

  defp add_miembro do
    tid = IO.gets("ID equipo: ") |> String.trim()
    uid = IO.gets("ID usuario: ") |> String.trim()
    name = IO.gets("Nombre usuario: ") |> String.trim()

    TeamManager.add_member(tid, %{id: uid, name: name})
    IO.puts("Miembro añadido!")
    loop()
  end

  # proyectos

  defp crear_proyecto do
    tid = IO.gets("ID del equipo dueño: ") |> String.trim()
    pid = IO.gets("ID del proyecto: ") |> String.trim()
    title = IO.gets("Título del proyecto: ") |> String.trim()
    desc = IO.gets("Descripción: ") |> String.trim()
    cat  = IO.gets("Categoría: ") |> String.trim()

    ProjectManager.create_project(tid, pid, title, desc, cat)
    IO.puts("Proyecto creado!")
    loop()
  end

  defp listar_proyectos do
    IO.inspect(ProjectManager.list_projects(), label: "Proyectos registrados")
    loop()
  end

  defp actualizar_avance do
    pid = IO.gets("ID del proyecto: ") |> String.trim()
    msg = IO.gets("Mensaje de avance: ") |> String.trim()

    ProjectManager.add_update(pid, msg)
    IO.puts("Avance registrado!")
    loop()
  end

  defp proyectos_categoria do
    cat = IO.gets("Categoría: ") |> String.trim()
    IO.inspect(ProjectManager.by_category(cat), label: "Proyectos en categoría")
    loop()
  end

  defp proyectos_equipo do
    tid = IO.gets("ID del equipo: ") |> String.trim()
    IO.inspect(ProjectManager.by_team(tid), label: "Proyectos del equipo")
    loop()
  end

  defp proyecto_id do
    pid = IO.gets("ID del proyecto: ") |> String.trim()
    IO.inspect(ProjectManager.get_project(pid), label: "Proyecto encontrado")
    loop()
  end

  # mensajeria

  defp enviar_mensaje do
    sala = IO.gets("Sala (general/team_x/sala_tema): ") |> String.trim()
    user = IO.gets("Usuario: ") |> String.trim()
    msg  = IO.gets("Mensaje: ") |> String.trim()

    ChatRoom.start_link(sala)
    ChatRoom.send_msg(sala, user, msg)

    IO.puts("Mensaje enviado!")
    loop()
  end

  defp ver_mensajes do
    sala = IO.gets("Sala: ") |> String.trim()
    IO.inspect(PersistenceETS.get_messages(sala), label: "Mensajes en sala")
    loop()
  end

#salida
  defp salir do
    IO.puts("Saliendo del sistema... ")
    System.halt(0)
  end
end

Menu.start()
