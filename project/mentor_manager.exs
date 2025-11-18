# Carga la capa de persistencia basada en ETS.
Code.require_file("persistence_ets.exs")

defmodule MentorManager do
  use GenServer

  # Inicia el GenServer que manejará el registro de mentores y su retroalimentación.
  def start_link(_), do: GenServer.start_link(__MODULE__, %{}, name: {:global, __MODULE__})

  # Estado inicial vacío; se usa únicamente como base para el GenServer.
  def init(state), do: {:ok, state}

  # Registra un mentor en ETS usando una clave marcada como {:mentor, id}.
  # meta debe contener los datos del mentor (ej. nombre, especialidad).
  def register_mentor(id, meta), do: GenServer.call(__MODULE__, {:create, id, meta})

  # Guarda un feedback asociado a un proyecto.
  # Cada retroalimentación incluye el mentor que la dio.
  def give_feedback(proj_id, mentor_id, feedback),
    do: GenServer.call(__MODULE__, {:fb, proj_id, mentor_id, feedback})

  # Recupera todos los feedback registrados para un proyecto específico.
  def get_feedback(proj_id), do: GenServer.call(__MODULE__, {:get_fb, proj_id})

  # Maneja el registro de mentores guardándolos en la tabla :teams usando una clave compuesta.
  def handle_call({:create, id, meta}, _from, state) do
    PersistenceETS.insert(:teams, {:mentor, id}, meta)
    {:reply, :ok, state}
  end

  # Agrega un mensaje de feedback asociado a un proyecto en la tabla :messages.
  # Se usa una clave especial {:feedback, proj_id}.
  def handle_call({:fb, proj, m, fb}, _from, state) do
    PersistenceETS.add_message({:feedback, proj}, %{
      mentor: m,
      fb: fb,
      ts: :os.system_time(:millisecond)
    })

    {:reply, :ok, state}
  end

  # Recupera todos los feedback asociados a un proyecto.
  def handle_call({:get_fb, proj}, _from, state) do
    {:reply, PersistenceETS.get_messages({:feedback, proj}), state}
  end
end
