defmodule Elixush.Instructions do
  @moduledoc "Defines a macro for importing all Elixush instructions at once."

  alias Elixush.PushState
  import Elixush.Instructions.{}

  defmacro __using__(_opts) do
    quote do
      require Logger
      modules = ["Common", "Integer", "Float", "Boolean"]
      Enum.each(modules, fn(module) ->
        {funcs, _args} = Code.eval_string("Elixush.Instructions.#{module}.__info__(:functions)")
        Enum.each(funcs, fn{f_atom, f_arity} ->
          f_string = Macro.to_string(f_atom)
          f_string = "&Elixush.Instructions.#{module}." <> String.trim(to_string(f_string), ":") <> "/" <> to_string(f_arity)
          {f_partial, _args} = Code.eval_string(f_string)
          PushState.define_registered(f_atom, f_partial)
        end)
      end)
      Logger.info("Elixush interpreter started!")
    end
  end
end
