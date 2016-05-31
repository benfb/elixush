defmodule Elixush.Instructions.FloatTest do
  use ExUnit.Case, async: true

  test ":float_add works properly" do
    assert Elixush.Server.run_program([1.0, 2.0, :float_add])
           |> Map.get(:float)
           |> List.first == 3.0
  end

  test ":float_sub works properly" do
    assert Elixush.Server.run_program([1.0, 2.0, :float_sub])
           |> Map.get(:float)
           |> List.first == -1.0
  end

  test ":float_mult works properly" do
    assert Elixush.Server.run_program([100.0, 2.0, :float_mult])
           |> Map.get(:float)
           |> List.first == 200.0
  end

  test ":float_div works properly" do
    assert Elixush.Server.run_program([100.0, 2.0, :float_div])
           |> Map.get(:float)
           |> List.first == 50.0
    assert Elixush.Server.run_program([100.0, 24.0, :float_div])
           |> Map.get(:float)
           |> List.first == 4.166666666666667
  end

  test ":float_lt works properly" do
    assert Elixush.Server.run_program([100.0, 2.0, :float_lt])
           |> Map.get(:boolean)
           |> List.first == false
  end

  test ":float_lte works properly" do
    assert Elixush.Server.run_program([100.0, 100.01, :float_lte])
           |> Map.get(:boolean)
           |> List.first == true
    assert Elixush.Server.run_program([100.0, 2.0, :float_lte])
           |> Map.get(:boolean)
           |> List.first == false
  end

  test ":float_gt works properly" do
    assert Elixush.Server.run_program([100.0, 2.0, :float_gt])
           |> Map.get(:boolean)
           |> List.first == true
  end

  test ":float_gte works properly" do
    assert Elixush.Server.run_program([100.01, 100.0, :float_gte])
           |> Map.get(:boolean)
           |> List.first == true
    assert Elixush.Server.run_program([100.0, 2.0, :float_gte])
           |> Map.get(:boolean)
           |> List.first == true
  end

  test ":float_fromboolean works properly" do
    assert Elixush.Server.run_program([true, :float_fromboolean])
           |> Map.get(:float)
           |> List.first == 1.0
    assert Elixush.Server.run_program([false, :float_fromboolean])
           |> Map.get(:float)
           |> List.first == 0.0
  end

  test ":float_frominteger works properly" do
    assert Elixush.Server.run_program([1, :float_frominteger])
           |> Map.get(:float)
           |> List.first == 1.0
    assert Elixush.Server.run_program([127, :float_frominteger])
           |> Map.get(:float)
           |> List.first == 127.0
  end

  test ":float_fromstring works properly" do
    assert Elixush.Server.run_program(["1.0", :float_fromstring])
           |> Map.get(:float)
           |> List.first == 1.0

    assert Elixush.Server.run_program(["127", :float_fromstring])
           |> Map.get(:float)
           |> List.first == nil
  end

  test ":float_min works properly" do
    assert Elixush.Server.run_program([1.0, 2.0, :float_min])
           |> Map.get(:float)
           |> List.first == 1.0
  end

  test ":float_max works properly" do
    assert Elixush.Server.run_program([1.0, 2.0, :float_max])
           |> Map.get(:float)
           |> List.first == 2.0
  end

  test ":float_inc works properly" do
    assert Elixush.Server.run_program([1.0, :float_inc])
           |> Map.get(:float)
           |> List.first == 2.0
  end

  test ":float_dec works properly" do
    assert Elixush.Server.run_program([0.0, :float_dec])
           |> Map.get(:float)
           |> List.first == -1.0
  end

end
