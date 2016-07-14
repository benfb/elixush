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


end
