Code.require_file("app_supervisor.exs")
Code.require_file("chat_room.exs")

TeamManager.create_team("team1", %{name: "Equipo 1"})
TeamManager.add_member("team1", %{id: "user1", name: "Ana"})

ProjectManager.create_project("team1", "proj1", %{title: "Idea A"})
ChatRoom.start_link("team1")
ChatRoom.send_msg("team1", "user1", "Hola equipo, subí avance 1")

MentorManager.register_mentor("m1", %{name: "Juan"})
MentorManager.give_feedback("proj1", "m1", "Buen avance, mejorar docs")


IO.inspect ProjectManager.get_project("proj1")
IO.inspect MentorManager.get_feedback("proj1")
