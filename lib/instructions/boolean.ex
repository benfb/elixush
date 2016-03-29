defmodule Exush.Instructions.Boolean do
  import Exush.PushState

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

  ### Common Instructions

  @doc "Returns a function that takes a state and pops the appropriate stack of the state."
  def boolean_pop(state), do: pop_item(:boolean, state)

  @doc """
  Returns a function that takes a state and duplicates the top item of the appropriate
  stack of the state.
  """
  def boolean_dup(state) do
    if Enum.empty?(state[:boolean]) do
      state
    else
      :boolean |> top_item(state) |> push_item(:boolean, state)
    end
  end

  @doc """
  Returns a function that takes a state and swaps the top 2 items of the appropriate
  stack of the state.
  """
  def boolean_swap(state) do
    if not(Enum.empty?(Enum.drop(state[:boolean], 1))) do
      first_item = stack_ref(:boolean, 0, state)
      second_item = stack_ref(:boolean, 1, state)
      push_item(second_item, :boolean, push_item(first_item, :boolean, pop_item(:boolean, pop_item(:boolean, state))))
    else
      state
    end
  end

  @doc """
  Returns a function that takes a state and rotates the top 3 items of the appropriate
  stack of the state.
  """
  def boolean_rot(state) do
    if not(Enum.empty?(Enum.drop(Enum.drop(state[:boolean], 1), 1))) do
      first = stack_ref(:boolean, 0, state)
      second = stack_ref(:boolean, 1, state)
      third = stack_ref(:boolean, 2, state)
      push_item(third, :boolean, push_item(first, :boolean, push_item(second, :boolean, pop_item(:boolean, pop_item(:boolean, pop_item(:boolean, state))))))
    else
      state
    end
  end

  @doc "Returns a function that empties the stack of the given state."
  def boolean_flush(state), do: Map.merge(state, %{:boolean => []})

  @doc """
  Returns a function that compares the top two items of the appropriate stack of
  the given state.
  """
  def boolean_eq(state) do
    if not(Enum.empty?(Enum.drop(state[:boolean], 1))) do
      first = stack_ref(:boolean, 0, state)
      second = stack_ref(:boolean, 1, state)
      push_item(first == second, :boolean, pop_item(:boolean, pop_item(:boolean, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the depth of the appropriate stack of the
  given state.
  """
  def boolean_stackdepth(state) do
    state[:boolean] |> length |> push_item(:integer, state)
  end

  @doc """
  Returns a function that yanks an item from deep in the specified stack,
  using the top integer to indicate how deep.
  """
  def boolean_yank(state) do
    if not(Enum.empty?(state[:boolean])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index = raw_index |> min(length(with_index_popped[:boolean]) - 1) |> max(0)
      item = stack_ref(:boolean, actual_index, with_index_popped)
      stk = with_index_popped[:boolean]
      with_item_pulled = Map.merge(with_index_popped, %{:boolean => Enum.concat(Enum.take(stk, actual_index), tl(Enum.drop(stk, actual_index)))})
      push_item(item, :boolean, with_item_pulled)
    else
      state
    end
  end

  @doc """
  Returns a function that yanks a copy of an item from deep in the specified stack,
  using the top integer to indicate how deep.
  """
  def boolean_yankdup(state) do
    if not(Enum.empty?(state[:boolean])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index = raw_index |> min(length(with_index_popped[:boolean]) - 1) |> max(0)
      item = stack_ref(:boolean, actual_index, with_index_popped)
      push_item(item, :boolean, with_index_popped)
    else
      state
    end
  end

  @doc """
  Returns a function that shoves an item deep in the specified stack, using the top
  integer to indicate how deep.
  """
  def boolean_shove(state) do
    if not(Enum.empty?(state[:boolean])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      item = top_item(:boolean, with_index_popped)
      with_args_popped = pop_item(:boolean, with_index_popped)
      actual_index = raw_index |> min(length(with_args_popped[:boolean])) |> max(0)
      stk = with_args_popped[:boolean]
      Map.merge(with_args_popped, %{:boolean => Enum.concat(Enum.take(stk, actual_index), [item], Enum.drop(stk, actual_index))})
    else
      state
    end
  end

  @doc "Returns a function that takes a state and tells whether that stack is empty."
  def boolean_empty(state), do: push_item(Enum.empty?(state[:boolean]), :boolean, state)
end
