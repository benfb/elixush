defmodule Exush do
  use Application
  import Exush.Interpreter
  import Exush.Instructions.Integer

  def start(_type, _args) do
    Exush.Supervisor.start_link
    # define_registered(:integer_mod, &integer_mod/1)
    # run_push([1, 2, :integer_mod], make_push_state)
  end

end
