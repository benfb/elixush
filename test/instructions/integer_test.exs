defmodule Elixush.Instructions.IntegerTest do
  use ExUnit.Case, async: true

  test ":integer_add works properly" do
    assert Elixush.Server.run_program([1, 2, :integer_add])
           |> Map.get(:integer)
           |> List.first == 3
    assert Elixush.Server.run_program(["test", true, :integer_add])
           |> Map.get(:integer)
           |> List.first == nil
  end

  test ":integer_sub works properly" do
    assert Elixush.Server.run_program([1, 2, :integer_sub])
           |> Map.get(:integer)
           |> List.first == -1
    assert Elixush.Server.run_program(["test", true, :integer_sub])
           |> Map.get(:integer)
           |> List.first == nil
  end

  test ":integer_mult works properly" do
    assert Elixush.Server.run_program([100, 2, :integer_mult])
           |> Map.get(:integer)
           |> List.first == 200
    assert Elixush.Server.run_program([1, true, :integer_mult])
           |> Map.get(:integer)
           |> List.first == 1
  end

  test ":integer_div works properly" do
    assert Elixush.Server.run_program([100, 2, :integer_div])
           |> Map.get(:integer)
           |> List.first == 50
    assert Elixush.Server.run_program([100, 24, :integer_div])
           |> Map.get(:integer)
           |> List.first == 4
    assert Elixush.Server.run_program([1, true, :integer_div])
           |> Map.get(:integer)
           |> List.first == 1
  end

  test ":integer_mod works properly" do
    assert Elixush.Server.run_program([100, 2, :integer_mod])
           |> Map.get(:integer)
           |> List.first == 0
    assert Elixush.Server.run_program([100, 24, :integer_mod])
           |> Map.get(:integer)
           |> List.first == 4
    assert Elixush.Server.run_program([1, true, :integer_mod])
           |> Map.get(:integer)
           |> List.first == 1
  end

  test ":integer_lt works properly" do
    refute Elixush.Server.run_program([100, 2, :integer_lt])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1, true, :integer_lt])
           |> Map.get(:integer)
           |> List.first == 1
  end

  test ":integer_lte works properly" do
    assert Elixush.Server.run_program([100, 100, :integer_lte])
           |> Map.get(:boolean)
           |> List.first
    refute Elixush.Server.run_program([100, 2, :integer_lte])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1, true, :integer_lte])
           |> Map.get(:boolean)
           |> List.first
  end

  test ":integer_gt works properly" do
    assert Elixush.Server.run_program([100, 2, :integer_gt])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1, "test", :integer_gt])
           |> Map.get(:boolean)
           |> List.first == nil
  end

  test ":integer_gte works properly" do
    assert Elixush.Server.run_program([100, 100, :integer_gte])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([100, 2, :integer_gte])
           |> Map.get(:boolean)
           |> List.first
    assert Elixush.Server.run_program([1, "test", :integer_gte])
           |> Map.get(:boolean)
           |> List.first == nil
  end

  test ":integer_fromboolean works properly" do
    assert Elixush.Server.run_program([true, :integer_fromboolean])
           |> Map.get(:integer)
           |> List.first == 1
    assert Elixush.Server.run_program([false, :integer_fromboolean])
           |> Map.get(:integer)
           |> List.first == 0
    assert Elixush.Server.run_program([1, "test", :integer_fromboolean])
           |> Map.get(:integer)
           |> List.first == 1
  end

  test ":integer_fromfloat works properly" do
    assert Elixush.Server.run_program([1.000000001, :integer_fromfloat])
           |> Map.get(:integer)
           |> List.first == 1
    assert Elixush.Server.run_program([127.0, :integer_fromfloat])
           |> Map.get(:integer)
           |> List.first == 127
    assert Elixush.Server.run_program([1, "test", :integer_fromfloat])
           |> Map.get(:integer)
           |> List.first == 1
  end

  test ":integer_fromstring works properly" do
    assert Elixush.Server.run_program(["1", :integer_fromstring])
           |> Map.get(:integer)
           |> List.first == 1
    assert Elixush.Server.run_program(["127.0", :integer_fromstring])
           |> Map.get(:integer)
           |> List.first == nil
    assert Elixush.Server.run_program([1, true, :integer_fromstring])
           |> Map.get(:integer)
           |> List.first == 1
  end

  test ":integer_min works properly" do
    assert Elixush.Server.run_program([1, 2, :integer_min])
           |> Map.get(:integer)
           |> List.first == 1
    assert Elixush.Server.run_program([1, :integer_min])
           |> Map.get(:integer)
           |> List.first == 1
  end

  test ":integer_max works properly" do
    assert Elixush.Server.run_program([1, 2, :integer_max])
           |> Map.get(:integer)
           |> List.first == 2
    assert Elixush.Server.run_program([1, :integer_max])
           |> Map.get(:integer)
           |> List.first == 1
  end

  test ":integer_inc works properly" do
    assert Elixush.Server.run_program([1, :integer_inc])
           |> Map.get(:integer)
           |> List.first == 2
    assert Elixush.Server.run_program(["test", true, :integer_inc])
           |> Map.get(:integer)
           |> List.first == nil
  end

  test ":integer_dec works properly" do
    assert Elixush.Server.run_program([0, :integer_dec])
           |> Map.get(:integer)
           |> List.first == -1
    assert Elixush.Server.run_program(["test", true, :integer_dec])
           |> Map.get(:integer)
           |> List.first == nil
  end

end
