defmodule Elixush.Instructions.BooleanTest do
  use ExUnit.Case, async: true

  test ":boolean_and works properly" do
    refute Elixush.Server.run_program([true, false, :boolean_and])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1, "test", true, :boolean_and])
           |> Map.get(:boolean)
           |> List.first
  end

  test ":boolean_or works properly" do
    assert Elixush.Server.run_program([true, false, :boolean_or])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1, "test", true, :boolean_or])
           |> Map.get(:boolean)
           |> List.first
  end

  test ":boolean_not works properly" do
    assert Elixush.Server.run_program([true, false, :boolean_not])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1, "test", :boolean_not])
           |> Map.get(:boolean)
           |> List.first == nil
  end

  test ":boolean_xor works properly" do
    assert Elixush.Server.run_program([true, false, :boolean_xor])
           |> Map.get(:boolean)
           |> List.first
    refute Elixush.Server.run_program([true, true, :boolean_xor])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1, "test", :boolean_xor])
           |> Map.get(:boolean)
           |> List.first == nil
  end

  test ":boolean_invert_first_then_and works properly" do
    assert Elixush.Server.run_program([true, false, :boolean_invert_first_then_and])
           |> Map.get(:boolean)
           |> List.first == true
    assert Elixush.Server.run_program([1, "test", true, :boolean_invert_first_then_and])
           |> Map.get(:boolean)
           |> List.first
  end

  test ":boolean_invert_second_then_and works properly" do
    assert Elixush.Server.run_program([false, true, :boolean_invert_second_then_and])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1, "test", true, :boolean_invert_second_then_and])
           |> Map.get(:boolean)
           |> List.first
  end

  test ":boolean_frominteger works properly" do
    refute Elixush.Server.run_program([0, :boolean_frominteger])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1, :boolean_frominteger])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([5, :boolean_frominteger])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1.0, "test", :boolean_frominteger])
           |> Map.get(:boolean)
           |> List.first == nil
  end

  test ":boolean_fromfloat works properly" do
    refute Elixush.Server.run_program([0.0, :boolean_fromfloat])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1.0, :boolean_fromfloat])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([5.0, :boolean_fromfloat])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1, "test", :boolean_fromfloat])
           |> Map.get(:boolean)
           |> List.first == nil
  end

end
