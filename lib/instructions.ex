defmodule Exush.Instructions do
  import Exush.Instructions.{}

  defmacro __using__(_opts) do
    quote do
      require Logger
      modules = ["Integer", "Boolean", "Float"]
      Enum.each(modules, fn(module) ->
        {funcs, _args} = Code.eval_string("Exush.Instructions.#{module}.__info__(:functions)")
        Enum.each(funcs, fn{f_atom, f_arity} ->
          f_string = Macro.to_string(f_atom)
          f_string = "&Exush.Instructions.#{module}." <> String.strip(to_string(f_string), ?:) <> "/" <> to_string(f_arity)
          {f_partial, _args} = Code.eval_string(f_string)
          Exush.PushState.define_registered(f_atom, f_partial)
        end)
      end)
      Logger.info("Instructions:\n#{inspect(Exush.Globals.Agent.get_globals(:instruction_table), pretty: true)}")
    end
  end
end
