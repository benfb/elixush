defmodule Elixush do
  use Application

  def start(_type, _args) do
    Elixush.Supervisor.start_link
  end

end
