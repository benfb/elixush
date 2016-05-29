defmodule Elixush.Server do
  use GenServer

  def start_link do
    use Elixush.Instructions
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def handle_call({:hey, name}, _from, state) do
    IO.puts "Hey, #{name}"
    {:reply, name, state}
  end

  def handle_call({:run, program}, _from, state) do
    result = Elixush.Interpreter.run_push(program, Elixush.PushState.make_push_state, true)
    {:reply, result, state}
  end

  def say_hi(name) do
    GenServer.call(__MODULE__, {:hey, name})
  end

  def run_program(program) do
    GenServer.call(__MODULE__, {:run, program})
  end
end
