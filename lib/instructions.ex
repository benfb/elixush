defmodule Elixush.Instructions do
  import Elixush.Instructions.{}

  defmacro __using__(_opts) do
    quote do
      require Logger
      modules = ["Common", "Integer", "Float", "Boolean"]
      Enum.each(modules, fn(module) ->
        {funcs, _args} = Code.eval_string("Elixush.Instructions.#{module}.__info__(:functions)")
        Enum.each(funcs, fn{f_atom, f_arity} ->
          f_string = Macro.to_string(f_atom)
          f_string = "&Elixush.Instructions.#{module}." <> String.strip(to_string(f_string), ?:) <> "/" <> to_string(f_arity)
          {f_partial, _args} = Code.eval_string(f_string)
          Elixush.PushState.define_registered(f_atom, f_partial)
        end)
      end)
      Logger.info("Instructions:\n#{inspect(Elixush.Globals.Agent.get_globals(:instruction_table), pretty: true)}")
    end
  end
end
