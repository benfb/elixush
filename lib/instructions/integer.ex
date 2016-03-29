defmodule Exush.Instructions.Integer do
  import Exush.PushState
  import Exush.Util

  @doc "Returns a function that pushes the sum of the top two items."
  def integer_add(state) do
    if not(state[:integer] |> Enum.drop(1) |> Enum.empty?) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      push_item(keep_number_reasonable(first + second), :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc "Returns a function that pushes the difference of the top two items."
  def integer_sub(state) do
    if not(Enum.empty?(tl(state[:integer]))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      push_item(keep_number_reasonable(second - first), :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc "Returns a function that pushes the product of the top two items."
  def integer_mult(state) do
    if not(Enum.empty?(tl(state[:integer]))) and not(stack_ref(:integer, 0, state) == 0) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = (second * first) |> keep_number_reasonable |> trunc
      push_item(item, :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the quotient of the top two items. Does
  nothing if the denominator would be zero.
  """
  def integer_div(state) do
    if not(Enum.empty?(tl(state[:integer]))) and not(stack_ref(:integer, 0, state) == 0) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = (second / first) |> keep_number_reasonable |> trunc
      push_item(item, :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the modulus of the top two items. Does
  nothing if the denominator would be zero.
  """
  def integer_mod(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) and not(stack_ref(:integer, 0, state) == 0) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      item = (rem(second, first)) |> keep_number_reasonable |> trunc
      push_item(item, :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  ### Comparers

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':integer' stack onto the boolean stack.
  """
  def integer_lt(state) do
    if not(Enum.empty?(tl(state[:integer]))) do
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
    if not(Enum.empty?(tl(state[:integer]))) do
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
    if not(Enum.empty?(tl(state[:integer]))) do
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
    if not(Enum.empty?(tl(state[:integer]))) do
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
    if not(Enum.empty?(tl(state[:integer]))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      push_item(min(second, first), :integer, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc "Returns a function that pushes the maximum of the top two items."
  def integer_max(state) do
    if not(Enum.empty?(tl(state[:integer]))) do
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

  ### Common Instructions

  @doc "Returns a function that takes a state and pops the appropriate stack of the state."
  def integer_pop(state), do: pop_item(:integer, state)

  @doc """
  Returns a function that takes a state and duplicates the top item of the appropriate
  stack of the state.
  """
  def integer_dup(state) do
    if Enum.empty?(state[:integer]) do
      state
    else
      :integer |> top_item(state) |> push_item(:integer, state)
    end
  end

  @doc """
  Returns a function that takes a state and swaps the top 2 items of the appropriate
  stack of the state.
  """
  def integer_swap(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      first_item = stack_ref(:integer, 0, state)
      second_item = stack_ref(:integer, 1, state)
      push_item(second_item, :integer, push_item(first_item, :integer, pop_item(:integer, pop_item(:integer, state))))
    else
      state
    end
  end

  @doc """
  Returns a function that takes a state and rotates the top 3 items of the appropriate
  stack of the state.
  """
  def integer_rot(state) do
    if not(Enum.empty?(Enum.drop(Enum.drop(state[:integer], 1), 1))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      third = stack_ref(:integer, 2, state)
      push_item(third, :integer, push_item(first, :integer, push_item(second, :integer, pop_item(:integer, pop_item(:integer, pop_item(:integer, state))))))
    else
      state
    end
  end

  @doc "Returns a function that empties the stack of the given state."
  def integer_flush(state), do: Map.merge(state, %{:integer => []})

  @doc """
  Returns a function that compares the top two items of the appropriate stack of
  the given state.
  """
  def integer_eq(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      first = stack_ref(:integer, 0, state)
      second = stack_ref(:integer, 1, state)
      push_item(first == second, :boolean, pop_item(:integer, pop_item(:integer, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the depth of the appropriate stack of the
  given state.
  """
  def integer_stackdepth(state) do
    state[:integer] |> length |> push_item(:integer, state)
  end

  @doc """
  Returns a function that yanks an item from deep in the specified stack,
  using the top integer to indicate how deep.
  """
  def integer_yank(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index = raw_index |> min(length(with_index_popped[:integer]) - 1) |> max(0)
      item = stack_ref(:integer, actual_index, with_index_popped)
      stk = with_index_popped[:integer]
      with_item_pulled = Map.merge(with_index_popped, %{:integer => Enum.concat(Enum.take(stk, actual_index), tl(Enum.drop(stk, actual_index)))})
      push_item(item, :integer, with_item_pulled)
    else
      state
    end
  end

  @doc """
  Returns a function that yanks a copy of an item from deep in the specified stack,
  using the top integer to indicate how deep.
  """
  def integer_yankdup(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index = raw_index |> min(length(with_index_popped[:integer]) - 1) |> max(0)
      item = stack_ref(:integer, actual_index, with_index_popped)
      push_item(item, :integer, with_index_popped)
    else
      state
    end
  end

  @doc """
  Returns a function that shoves an item deep in the specified stack, using the top
  integer to indicate how deep.
  """
  def integer_shove(state) do
    if not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      item = top_item(:integer, with_index_popped)
      with_args_popped = pop_item(:integer, with_index_popped)
      actual_index = raw_index |> min(length(with_args_popped[:integer])) |> max(0)
      stk = with_args_popped[:integer]
      Map.merge(with_args_popped, %{:integer => Enum.concat(Enum.take(stk, actual_index), [item], Enum.drop(stk, actual_index))})
    else
      state
    end
  end

  @doc "Returns a function that takes a state and tells whether that stack is empty."
  def integer_empty(state), do: push_item(Enum.empty?(state[:integer]), :integer, state)
end
