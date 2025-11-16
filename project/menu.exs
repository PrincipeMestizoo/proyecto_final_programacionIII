# Arranque automatico del supervisor en caso error de carga

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

# Actualizacion de menu

defmodule Menu do
  def start do
    AutoStart.ensure_supervisor_running()
    loop()
  end

  defp loop do
    IO.puts("""
    -----------------------------
            MENÚ PRINCIPAL
    -----------------------------
    1. Crear equipo
    2. Listar equipos
    3. Añadir miembro al equipo
    4. Crear proyecto
    5. Listar proyectos
    6. Enviar mensaje a sala
    7. Ver mensajes de una sala
    0. Salir
    -----------------------------
    """)

    opcion =
      IO.gets("Seleccione una opción: ")
      |> String.trim()

    case opcion do
      "1" ->
        crear_equipo()

      "2" ->
        listar_equipos()

      "3" ->
        add_miembro()

      "4" ->
        crear_proyecto()

      "5" ->
        listar_proyectos()

      "6" ->
        enviar_msg()

      "7" ->
        ver_msg()

      "0" ->
        salir()

      _ ->
        IO.puts("Opción inválida.")
        loop()
    end
  end

  # Funcionalidades

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

  defp crear_proyecto do
    tid = IO.gets("ID equipo dueño: ") |> String.trim()
    pid = IO.gets("ID proyecto: ") |> String.trim()
    titulo = IO.gets("Título: ") |> String.trim()

    ProjectManager.create_project(tid, pid, %{title: titulo})

    IO.puts("Proyecto creado!")
    loop()
  end

  defp listar_proyectos do
    IO.inspect(ProjectManager.list_projects(), label: "Proyectos")
    loop()
  end

  defp enviar_msg do
    sala = IO.gets("Sala: ") |> String.trim()
    user = IO.gets("Usuario: ") |> String.trim()
    msg = IO.gets("Mensaje: ") |> String.trim()

    # si ya existe, no pasa nada
    ChatRoom.start_link(sala)

    ChatRoom.send_msg(sala, user, msg)

    IO.puts("Mensaje enviado!")
    loop()
  end

  defp ver_msg do
    sala = IO.gets("Sala: ") |> String.trim()

    IO.inspect(PersistenceETS.get_messages(sala), label: "Mensajes")

    loop()
  end

  defp salir do
    IO.puts("Saliendo del sistema… Adiós!")
    System.halt(0)
  end
end

Menu.start()
