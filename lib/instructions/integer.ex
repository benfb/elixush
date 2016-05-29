defmodule Elixush.Instructions.Integer do
  @moduledoc "Instructions that operate on the integer stack."

  import Elixush.PushState
  import Elixush.Util

  @doc "Pushes the sum of the top two items."
  def integer_add(state) do
    if not(state[:integer] |> Enum.drop(1) |> Enum.empty?) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      push_item(keep_number_reasonable(first + second), :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc "Pushes the difference of the top two items."
  def integer_sub(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      push_item(keep_number_reasonable(second - first), :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc "Pushes the product of the top two items."
  def integer_mult(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) and not(stack_ref(:integer, 0, state) == 0) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = (second * first) |> keep_number_reasonable
      push_item(item, :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc """
  Pushes the quotient of the top two items. Does nothing if
  the denominator would be zero.
  """
  def integer_div(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) and not(stack_ref(:integer, 0, state) == 0) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = second |> div(first) |> keep_number_reasonable |> trunc
      push_item(item, :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc """
  Pushes the modulus of the top two items. Does nothing if
  the denominator would be zero.
  """
  def integer_mod(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) and not(stack_ref(:integer, 0, state) == 0) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = second |> rem(first) |> keep_number_reasonable |> trunc
      push_item(item, :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  ### Comparers

  @doc """
  Pushes the result of comparator of the top two items
  on the ':integer' stack onto the boolean stack.
  """
  def integer_lt(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = second < first
      push_item(item, :boolean, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':integer' stack onto the boolean stack.
  """
  def integer_lte(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = second <= first
      push_item(item, :boolean, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':integer' stack onto the boolean stack.
  """
  def integer_gt(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = second > first
      push_item(item, :boolean, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':integer' stack onto the boolean stack.
  """
  def integer_gte(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = second >= first
      push_item(item, :boolean, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  def integer_fromboolean(state) do
    if not(Enum.empty?(state[:boolean])) do
      item = stack_ref(:boolean, 0, state)
      to_push = if item do 1 else 0 end
      push_item(to_push, :integer, pop_item(:boolean, state))
    else
      state
    end
  end

  def integer_fromfloat(state) do
    if not(Enum.empty?(state[:float])) do
      item = stack_ref(:float, 0, state)
      push_item(trunc(item), :integer, pop_item(:float, state))
    else
      state
    end
  end

  def integer_fromstring(state) do
    if not(Enum.empty?(state[:string])) do
      try do
        pop_item(:string, push_item(keep_number_reasonable(String.to_integer(top_item(:string, state))), :integer, state))
      rescue
        e in ArgumentError -> {e, state}
      end
    else
      state
    end
  end

  # TODO: Add integer_fromchar

  @doc "Returns a function that pushes the minimum of the top two items."
  def integer_min(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      push_item(min(second, first), :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc "Returns a function that pushes the maximum of the top two items."
  def integer_max(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      push_item(max(second, first), :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  def integer_inc(state) do
    if not(Enum.empty?(state[:integer])) do
      push_item(keep_number_reasonable(stack_ref(:integer, 0, state)) + 1, :integer, pop_item(:integer, state))
    else
      state
    end
  end

  def integer_dec(state) do
    if not(Enum.empty?(state[:integer])) do
      push_item(keep_number_reasonable(stack_ref(:integer, 0, state)) - 1, :integer, pop_item(:integer, state))
    else
      state
    end
  end

end
