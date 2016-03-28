defmodule Exush.Instructions.Integer do
  import Exush.Interpreter

  def integer_add(state) do
    if not(Enum.empty?(tl(state[:integer]))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      push_item(first + second, :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  def integer_sub(state) do
    if not(Enum.empty?(tl(state[:integer]))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      push_item(second - first, :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  def integer_mod(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) and not(stack_ref(:integer, 0, state) == 0) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = (rem(second, first)) |> trunc
      push_item(item, :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end
end
