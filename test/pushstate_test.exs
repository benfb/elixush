defmodule Elixush.PushStateTest do
  use ExUnit.Case, async: true
  import Elixush.PushState
  # alias Elixush.Server

  test "the result of make_push_state is empty" do
    state = make_push_state
    assert state |> Map.get(:boolean) |> List.first == nil
    assert state |> Map.get(:integer) |> List.first == nil
    assert state |> Map.get(:string) |> List.first == nil
  end

  test "push_item pushes an item successfully" do
    assert push_item(true, :boolean, make_push_state)
           |> Map.get(:boolean)
           |> List.first
  end

  test "register_instruction registers an instruction successfully" do
    assert register_instruction(:integer_test) == :ok
    assert_raise ArgumentError, fn ->
      register_instruction(:integer_test)
    end
  end

  test "registered_for_type returns correct instructions" do
    assert registered_for_type(:boolean) |> Enum.member?(:boolean_and)
    refute registered_for_type(:boolean) |> Enum.member?(:integer_gte)
    assert registered_for_type(:genome, include_randoms: false)
           |> Enum.member?(:genome_gene_dup)
  end

  test "registered_nonrandom returns correct instructions" do
    assert registered_nonrandom() |> Enum.member?(:boolean_and)
    refute registered_nonrandom() |> Enum.member?(:autoconstructive_integer_rand)
  end


end
