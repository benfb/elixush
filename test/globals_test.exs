defmodule Elixush.GlobalsTest do
  use ExUnit.Case, async: true
  # # run with --no-start
  # setup_all do
  #   {:ok, globals} = Elixush.Globals.Agent.start_link(Elixush.Globals.Agent)
  #   {:ok, globals: globals}
  # end

  test "stores values by key" do
    assert Elixush.Globals.Agent.get_globals(:milk) == nil
    assert Elixush.Globals.Agent.get_globals(:max_vector_length) == 5000

    Elixush.Globals.Agent.update_globals(:milk, 3)
    assert Elixush.Globals.Agent.get_globals(:milk) == 3
  end

end
