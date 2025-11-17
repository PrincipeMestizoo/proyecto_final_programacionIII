# Crea las tablas ETS necesarias para el sistema.
# :teams y :projects usan tipo :set (solo un registro por clave).
# :messages usa :bag (permite múltiples registros por clave).
# Se usa try/rescue para evitar errores si la tabla ya existe.

for table <- [:teams, :projects, :messages] do
  try do
    type = if table == :messages, do: :bag, else: :set
    :ets.new(table, [:named_table, type, :public, read_concurrency: true])
  rescue
    _ -> :ok
  end
end

defmodule PersistenceETS do
  # Inserta un valor en la tabla ETS bajo una clave dada.
  def insert(table, key, value), do: :ets.insert(table, {key, value})

  # Obtiene un valor desde ETS usando su clave.
  # Devuelve {:ok, value} si existe o :error si no existe.
  def get(table, key) do
    case :ets.lookup(table, key) do
      [{^key, v}] -> {:ok, v}
      _ -> :error
    end
  end

  # Devuelve todos los elementos de la tabla.
  def all(table), do: :ets.tab2list(table)

  # Elimina una entrada por clave.
  def delete(table, key), do: :ets.delete(table, key)

  # Guarda un mensaje dentro de la tabla :messages asociándolo a una sala.
  def add_message(room, msg), do: :ets.insert(:messages, {room, msg})

  # Recupera todos los mensajes asociados a una sala.
  # lookup devuelve tuplas {room, msg}, por eso se hace un map para extraer msg.
  def get_messages(room) do
    :ets.lookup(:messages, room)
    |> Enum.map(fn {_, m} -> m end)
  end
end
