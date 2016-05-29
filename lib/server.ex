defmodule Elixush.Server do
  @moduledoc "An OTP server that listens for calls to run Push programs."
  alias Elixush.Interpreter
  alias Elixush.Instructions
  alias Elixush.PushState
  use GenServer

  def start_link do
    use Instructions
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def handle_call({:run, program}, _from, state) do
    result = Interpreter.run_push(program, PushState.make_push_state, true)
    {:reply, result, state}
  end

  def run_program(program) do
    GenServer.call(__MODULE__, {:run, program})
  end
end
