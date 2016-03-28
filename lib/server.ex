defmodule Exush.Server do
  use GenServer

  def start_link do
    Exush.Interpreter.define_registered(:integer_mod, &Exush.Instructions.Integer.integer_mod/1)
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def handle_call({:hey, name}, _from, state) do
    IO.puts "Hey, #{name}"
    {:reply, name, state}
  end

  def handle_call({:run, program}, _from, state) do
    result = Exush.Interpreter.run_push(program, Exush.Interpreter.make_push_state)
    {:reply, result, state}
  end

  def say_hi(name) do
    GenServer.call(__MODULE__, {:hey, name})
  end

  def run_program(program) do
    GenServer.call(__MODULE__, {:run, program})
  end
end
