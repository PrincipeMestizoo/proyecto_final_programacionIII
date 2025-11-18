Code.require_file("team_manager.exs")
Code.require_file("project_manager.exs")
Code.require_file("mentor_manager.exs")
Code.require_file("chat_pubsub.exs")
Code.require_file("chat_room.exs")
Code.require_file("persistence_ets.exs")
Code.require_file("app_supervisor.exs") # Aseguramos supervisor disponible

# =========================================================
# ARRANQUE AUTOMÁTICO
# =========================================================
defmodule AutoStart do
  def ensure_supervisor_running do
    # Verifica si los GenServers globales ya existen
    tm = :global.whereis_name(TeamManager)
    pm = :global.whereis_name(ProjectManager)
    mm = :global.whereis_name(MentorManager)
    pub = :global.whereis_name(ChatPubSub)

    # Si alguno no existe, arranca el supervisor global
    if tm == :undefined or pm == :undefined or mm == :undefined or pub == :undefined do
      IO.puts("\n>>> No hay supervisor activo. Arrancando AppSupervisor...\n")
      {:ok, _} = AppSupervisor.start_link(nil)
    else
      :ok
    end
  end
end

# =========================================================
# MENÚ PRINCIPAL
# =========================================================
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

  # =====================================================
  # EQUIPOS
  # =====================================================
  defp crear_equipo do
    id = IO.gets("ID del equipo: ") |> String.trim()
    nombre = IO.gets("Nombre del equipo: ") |> String.trim()
    # Llamada global segura
    GenServer.call({:global, TeamManager}, {:create, id, %{name: nombre}})
    IO.puts("Equipo creado correctamente!")
    loop()
  end

  defp listar_equipos do
    res = GenServer.call({:global, TeamManager}, :list)
    IO.inspect(res, label: "Equipos registrados")
    loop()
  end

  defp add_miembro do
    id = IO.gets("ID equipo: ") |> String.trim()
    uid = IO.gets("ID usuario: ") |> String.trim()
    nombre = IO.gets("Nombre usuario: ") |> String.trim()
    GenServer.call({:global, TeamManager}, {:add_member, id, %{id: uid, name: nombre}})
    IO.puts("Miembro añadido!")
    loop()
  end

  # =====================================================
  # PROYECTOS
  # =====================================================
  defp crear_proyecto do
    tid = IO.gets("ID equipo dueño: ") |> String.trim()
    pid = IO.gets("ID proyecto: ") |> String.trim()
    titulo = IO.gets("Título del proyecto: ") |> String.trim()
    desc = IO.gets("Descripción: ") |> String.trim()
    cat = IO.gets("Categoría: ") |> String.trim()
    GenServer.call({:global, ProjectManager}, {:create, tid, pid, titulo, desc, cat, :os.system_time(:second)})
    IO.puts("Proyecto creado!")
    loop()
  end

  defp listar_proyectos do
    res = GenServer.call({:global, ProjectManager}, :list)
    IO.inspect(res, label: "Proyectos")
    loop()
  end

  # =====================================================
  # CHAT
  # =====================================================
  defp enviar_msg do
    sala = IO.gets("Sala: ") |> String.trim()
    user = IO.gets("Usuario: ") |> String.trim()
    msg  = IO.gets("Mensaje: ") |> String.trim()

    # Intento de iniciar la sala, si ya existe ignoramos error
    case ChatRoom.start_link(sala) do
      {:ok, _pid} -> :ok
      {:error, {:already_started, _pid}} -> :ok
      _ -> IO.puts("Error al iniciar la sala")
    end

    ChatRoom.send_msg(sala, user, msg)
    IO.puts("Mensaje enviado!")
    loop()
  end

  defp ver_msg do
    sala = IO.gets("Sala: ") |> String.trim()
    msgs = PersistenceETS.get_messages(sala)
    IO.inspect(msgs, label: "Mensajes en sala")
    loop()
  end

  # =====================================================
  # MENTORIA
  # =====================================================
  defp registrar_mentor do
    id = IO.gets("ID del mentor: ") |> String.trim()
    nombre = IO.gets("Nombre del mentor: ") |> String.trim()
    area = IO.gets("Área o especialidad: ") |> String.trim()
    GenServer.call({:global, MentorManager}, {:create, id, %{name: nombre, area: area}})
    IO.puts("Mentor registrado correctamente!")
    loop()
  end

  defp enviar_feedback do
    proj = IO.gets("ID del proyecto: ") |> String.trim()
    ment = IO.gets("ID del mentor: ") |> String.trim()
    fb   = IO.gets("Retroalimentación: ") |> String.trim()
    GenServer.call({:global, MentorManager}, {:fb, proj, ment, fb})
    IO.puts("Feedback enviado!")
    loop()
  end

  defp ver_feedback do
    proj = IO.gets("ID del proyecto: ") |> String.trim()
    feedback = GenServer.call({:global, MentorManager}, {:get_fb, proj})
    IO.inspect(feedback, label: "Feedback del proyecto")
    loop()
  end

  # =====================================================
  # SALIDA
  # =====================================================
  defp salir do
    IO.puts("Saliendo del sistema… Adiós!")
    System.halt(0)
  end
end
