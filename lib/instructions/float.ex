defmodule Elixush.Instructions.Float do
  import Elixush.PushState
  import Elixush.Util

  @doc "Returns a function that pushes the sum of the top two items."
  def float_add(state) do
    if not(Enum.empty?(tl(state[:float]))) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      push_item(keep_number_reasonable(first + second), :float, pop_item(:float, pop_item(:float, state)))
    else
      state
    end
  end

  @doc "Returns a function that pushes the difference of the top two items."
  def float_sub(state) do
    if not(Enum.empty?(tl(state[:float]))) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      push_item(keep_number_reasonable(second - first), :float, pop_item(:float, pop_item(:float, state)))
    else
      state
    end
  end

  @doc "Returns a function that pushes the product of the top two items."
  def float_mult(state) do
    if not(Enum.empty?(tl(state[:integer]))) and not(stack_ref(:integer, 0, state) == 0) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = (second * first) |> keep_number_reasonable |> trunc
      push_item(item, :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc "Returns a function that pushes the product of the top two items."
  def float_div(state) do
    if not(Enum.empty?(tl(state[:float]))) and not(stack_ref(:float, 0, state) == 0) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      item = (second / first) |> keep_number_reasonable
      push_item(item, :float, pop_item(:float, pop_item(:float, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the modulus of the top two items. Does
  nothing if the denominator would be zero.
  """
  def float_mod(state) do
    if not(Enum.empty?(Enum.drop(state[:float], 1))) and not(stack_ref(:float, 0, state) == 0) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      item = (rem(second, first)) |> keep_number_reasonable
      push_item(item, :float, pop_item(:float, pop_item(:float, state)))
    else
      state
    end
  end

  ### Comparers

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':float' stack onto the boolean stack.
  """
  def float_lt(state) do
    if not(Enum.empty?(tl(state[:float]))) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      item = second < first
      push_item(item, :boolean, pop_item(:float, pop_item(:float, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':float' stack onto the boolean stack.
  """
  def float_lte(state) do
    if not(Enum.empty?(tl(state[:float]))) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      item = second <= first
      push_item(item, :boolean, pop_item(:float, pop_item(:float, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':float' stack onto the boolean stack.
  """
  def float_gt(state) do
    if not(Enum.empty?(tl(state[:float]))) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      item = second > first
      push_item(item, :boolean, pop_item(:float, pop_item(:float, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':float' stack onto the boolean stack.
  """
  def float_gte(state) do
    if not(Enum.empty?(tl(state[:float]))) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      item = second >= first
      push_item(item, :boolean, pop_item(:float, pop_item(:float, state)))
    else
      state
    end
  end

  def float_fromboolean(state) do
    if not(Enum.empty?(state[:boolean])) do
      item = stack_ref(:boolean, 0, state)
      to_push = if item do 1.0 else 0.0 end
      push_item(to_push, :float, pop_item(:boolean, state))
    else
      state
    end
  end

  def float_frominteger(state) do
    if not(Enum.empty?(state[:integer])) do
      item = stack_ref(:integer, 0, state)
      push_item(item * 1.0, :float, pop_item(:integer, state))
    else
      state
    end
  end

  def float_fromstring(state) do
    if not(Enum.empty?(state[:string])) do
      try do
        pop_item(:string, push_item(keep_number_reasonable(String.to_float(top_item(:string, state))), :float, state))
      rescue
        e in ArgumentError -> {e, state}
      end
    else
      state
    end
  end

  # TODO: Add float_fromchar

  @doc "Returns a function that pushes the minimum of the top two items."
  def float_min(state) do
    if not(Enum.empty?(tl(state[:float]))) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      push_item(min(second, first), :float, pop_item(:float, pop_item(:float, state)))
    else
      state
    end
  end

  @doc "Returns a function that pushes the maximum of the top two items."
  def float_max(state) do
    if not(Enum.empty?(tl(state[:float]))) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      push_item(max(second, first), :float, pop_item(:float, pop_item(:float, state)))
    else
      state
    end
  end

  def float_sin(state) do
    if not(Enum.empty?(state[:float])) do
      push_item(keep_number_reasonable(:math.sin(stack_ref(:float, 0, state))), :float, pop_item(:float, state))
    else
      state
    end
  end

  def float_cos(state) do
    if not(Enum.empty?(state[:float])) do
      push_item(keep_number_reasonable(:math.cos(stack_ref(:float, 0, state))), :float, pop_item(:float, state))
    else
      state
    end
  end

  def float_tan(state) do
    if not(Enum.empty?(state[:float])) do
      push_item(keep_number_reasonable(:math.tan(stack_ref(:float, 0, state))), :float, pop_item(:float, state))
    else
      state
    end
  end

  def float_inc(state) do
    if not(Enum.empty?(state[:float])) do
      push_item(keep_number_reasonable(stack_ref(:float, 0, state)) + 1.0, :float, pop_item(:float, state))
    else
      state
    end
  end

  def float_dec(state) do
    if not(Enum.empty?(state[:float])) do
      push_item(keep_number_reasonable(stack_ref(:float, 0, state)) - 1.0, :float, pop_item(:float, state))
    else
      state
    end
  end

end
