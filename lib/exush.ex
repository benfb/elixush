defmodule Exush do
  use Application

  def start(_type, _args) do
    Exush.Supervisor.start_link
  end

end
