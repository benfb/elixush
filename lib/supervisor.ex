defmodule Elixush.Supervisor do
  @moduledoc "An OTP supervisor that keeps agents and servers running."
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    children = [
      worker(Elixush.Globals.Agent, [Elixush.Globals.Agent]),
      worker(Elixush.Server, [])
    ]

    supervise(children, strategy: :one_for_all)
  end
end
