defmodule Elixush.Instructions.Boolean do
  import Elixush.PushState

  def boolean_and(state) do
    if not(state[:boolean] |> Enum.drop(1) |> Enum.empty?) do
      to_push = stack_ref(:boolean, 0, state) and stack_ref(:boolean, 1, state)
      push_item(to_push, :boolean, pop_item(:boolean, pop_item(:boolean, state)))
    else
      state
    end
  end

  def boolean_or(state) do
    if not(state[:boolean] |> Enum.drop(1) |> Enum.empty?) do
      to_push = stack_ref(:boolean, 0, state) or stack_ref(:boolean, 1, state)
      push_item(to_push, :boolean, pop_item(:boolean, pop_item(:boolean, state)))
    else
      state
    end
  end

  def boolean_not(state) do
    if not(state[:boolean] |> Enum.empty?) do
      to_push = not(stack_ref(:boolean, 0, state))
      push_item(to_push, :boolean, pop_item(:boolean, state))
    else
      state
    end
  end

  def boolean_xor(state) do
    if not(state[:boolean] |> Enum.drop(1) |> Enum.empty?) do
      to_push = not(stack_ref(:boolean, 0, state) == stack_ref(:boolean, 1, state))
      push_item(to_push, :boolean, pop_item(:boolean, pop_item(:boolean, state)))
    else
      state
    end
  end

  def boolean_invert_first_then_and(state) do
    if not(state[:boolean] |> Enum.drop(1) |> Enum.empty?) do
      to_push = not(stack_ref(:boolean, 0, state)) and stack_ref(:boolean, 1, state)
      push_item(to_push, :boolean, pop_item(:boolean, pop_item(:boolean, state)))
    else
      state
    end
  end

  def boolean_invert_second_then_and(state) do
    if not(state[:boolean] |> Enum.drop(1) |> Enum.empty?) do
      to_push = stack_ref(:boolean, 0, state) and not(stack_ref(:boolean, 1, state))
      push_item(to_push, :boolean, pop_item(:boolean, pop_item(:boolean, state)))
    else
      state
    end
  end

  def boolean_frominteger(state) do
    if not(state[:integer] |> Enum.empty?) do
      to_push = not(stack_ref(:integer, 0, state) == 0)
      push_item(to_push, :boolean, pop_item(:integer, state))
    else
      state
    end
  end

  def boolean_fromfloat(state) do
    if not(state[:float] |> Enum.empty?) do
      to_push = not(stack_ref(:float, 0, state) == 0)
      push_item(to_push, :boolean, pop_item(:float, state))
    else
      state
    end
  end

end
