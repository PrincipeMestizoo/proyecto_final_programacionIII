Code.require_file("app_supervisor.exs")

IO.puts("""
==========================
 DEMOSTRACIÓN DEL SISTEMA
==========================
""")

IO.puts("1) Creando equipo...")
TeamManager.create_team("demo", %{name: "Equipo 1", members: []})

IO.puts("2) Creando proyecto...")
ProjectManager.create_project("demo", "proj", %{title: "Proyecto Final"})

IO.puts("3) Agregando mentor...")
MentorManager.register_mentor("mentor", %{name: "Jhan"})

IO.puts("4) Mentor deja feedback...")
MentorManager.give_feedback("proj", "Jhan", "Comentario excelente")

IO.puts("5) Chat en tiempo real simulación...")
ChatPubSub.broadcast("sal_test", {self(), "daniel", "Hola desde test!"})
Process.sleep(200)

IO.puts("\nRESULTADOS:")
IO.inspect(TeamManager.get_team("demo"))
IO.inspect(ProjectManager.get_project("proj"))
IO.inspect(MentorManager.get_feedback("proj"))
IO.inspect(PersistenceETS.get_messages("sal_test"))

IO.puts("\n=== DEMO FINALIZADO ===")
