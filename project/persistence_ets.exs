# Crea las tablas ETS necesarias para el sistema
for table <- [:teams, :projects, :messages, :mentors, :feedback] do
  try do
    type = if table in [:messages, :feedback], do: :bag, else: :set
    :ets.new(table, [:named_table, type, :public, read_concurrency: true])
  rescue
    _ -> :ok
  end
end

defmodule PersistenceETS do
  # Inserta un valor en la tabla ETS
  def insert(table, key, value), do: :ets.insert(table, {key, value})

  # Obtiene un valor desde ETS
  def get(table, key) do
    case :ets.lookup(table, key) do
      [{^key, v}] -> {:ok, v}
      _ -> :error
    end
  end

  # Devuelve todos los elementos de la tabla
  def all(table), do: :ets.tab2list(table)

  # Elimina una entrada por clave
  def delete(table, key), do: :ets.delete(table, key)

  # Agrega un mensaje a la tabla :messages
  def add_message(room, msg), do: :ets.insert(:messages, {room, msg})

  # Recupera todos los mensajes de una sala
  def get_messages(room) do
    :ets.lookup(:messages, room)
    |> Enum.map(fn {_, m} -> m end)
  end

  # Agrega feedback a la tabla :feedback
  def add_feedback(proj, fb), do: :ets.insert(:feedback, {proj, fb})

  # Obtiene feedback de un proyecto
  def get_feedback(proj) do
    :ets.lookup(:feedback, proj)
    |> Enum.map(fn {_, fb} -> fb end)
  end
end
