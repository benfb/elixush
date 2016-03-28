defmodule Exush.Instructions do
  import Exush.Instructions.{}

  defmacro __using__(_opts) do
    quote do
      modules = ["Integer"]
      Enum.each(modules, fn(module) ->
        funcs = Exush.Instructions.Integer.__info__(:functions)
        Enum.each(funcs, fn{f_atom, f_arity} ->
          IO.puts "#{f_atom}, #{f_arity}"
          IO.puts Macro.to_string(f_arity)
          f_string = Macro.to_string(f_atom)
          f_string = ("&Exush.Instructions.#{module}." <> String.strip(to_string(f_string), ?:)) <> ("/" <> to_string(f_arity))
          IO.puts f_string
          #f = apply(Exush.Instructions.Integer, f_atom, [])
          # Code.eval_string(f_string, requires: [Exush.Instructions.Integer])
          {f_partial, _args} = Code.eval_string(f_string)
          Exush.Interpreter.define_registered(f_atom, f_partial)
        end)
      end)
    end
  end
end
