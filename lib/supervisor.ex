defmodule Exush.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Exush.Globals.Agent, [Exush.Globals.Agent]),
      worker(Exush.Server, [])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
