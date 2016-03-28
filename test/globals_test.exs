defmodule Exush.GlobalsTest do
  use ExUnit.Case, async: true
  # run with --no-start
  setup do
    {:ok, globals} = Exush.Globals.start_link(Exush.Globals)
    {:ok, globals: globals}
  end

  test "stores values by key" do
    assert Exush.Globals.get_globals(:milk) == nil
    assert Exush.Globals.get_globals(:max_vector_length) == 5000

    Exush.Globals.update_globals(:milk, 3)
    assert Exush.Globals.get_globals(:milk) == 3
  end

end
