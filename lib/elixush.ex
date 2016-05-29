defmodule Elixush do
  @moduledoc "An OTP application that evaluates Push programs."
  use Application

  def start(_type, _args) do
    Elixush.Supervisor.start_link
  end

end
