defmodule Hola do
  use GenServer

  def start_link(_) do
    IO.puts(">>> start_link ejecutado")
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_) do
    IO.puts(">>> init ejecutado")
    {:ok, nil}
  end
end

defmodule Sup do
  use Supervisor

  def start_link(_) do
    IO.puts(">>> SUPERVISOR arrancando")
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    IO.puts(">>> init supervisor")
    children = [
      {Hola, []}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end

{:ok, _pid} = Sup.start_link(nil)

IO.inspect(Process.whereis(Hola), label: "PID Hola")
Process.sleep(:infinity)
