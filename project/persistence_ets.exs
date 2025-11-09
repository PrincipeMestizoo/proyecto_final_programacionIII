for table <- [:teams, :projects, :messages] do
  try do
    type = if table == :messages, do: :bag, else: :set
    :ets.new(table, [:named_table, type, :public, read_concurrency: true])
  rescue
    _ -> :ok
  end
end

defmodule PersistenceETS do
  def insert(table, key, value), do: :ets.insert(table, {key, value})

  def get(table, key) do
    case :ets.lookup(table, key) do
      [{^key, v}] -> {:ok, v}
      _ -> :error
    end
  end

  def all(table), do: :ets.tab2list(table)
  def delete(table, key), do: :ets.delete(table, key)

  def add_message(room, msg), do: :ets.insert(:messages, {room, msg})

  def get_messages(room) do
    :ets.lookup(:messages, room)
    |> Enum.map(fn {_, m} -> m end)
  end
end
