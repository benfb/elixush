defmodule Exush.Instructions do
  use Application
  import Exush.Interpreter


  defmacro __using__(opts) do
    quote do
      import Exush.Instructions.Integer
    end
  end
end
