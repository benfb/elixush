defmodule Elixush.Instructions.BooleanTest do
  use ExUnit.Case, async: true

  test ":boolean_and works properly" do
    assert Elixush.Server.run_program([true, false, :boolean_and])
           |> Map.get(:boolean)
           |> List.first() == false
  end

  test ":boolean_or works properly" do
    assert Elixush.Server.run_program([true, false, :boolean_or])
           |> Map.get(:boolean)
           |> List.first() == false
  end

end
