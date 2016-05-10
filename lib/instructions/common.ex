defmodule Elixush.Instructions.Common do
  import Elixush.PushState

  ### EXEC
  @doc "Returns a function that takes a state and pops the appropriate stack of the state."
  def exec_pop(state), do: pop_item(:exec, state)

  @doc """
  Returns a function that takes a state and duplicates the top item of the appropriate
  stack of the state.
  """
  def exec_dup(state) do
    if Enum.empty?(state[:exec]) do
      state
    else
      :exec |> top_item(state) |> push_item(:exec, state)
    end
  end

  @doc """
  Returns a function that takes a state and swaps the top 2 items of the appropriate
  stack of the state.
  """
  def exec_swap(state) do
    if not(Enum.empty?(Enum.drop(state[:exec], 1))) do
      first_item = stack_ref(:exec, 0, state)
      second_item = stack_ref(:exec, 1, state)
      push_item(second_item, :exec, push_item(first_item, :exec, pop_item(:exec, pop_item(:exec, state))))
    else
      state
    end
  end

  @doc """
  Returns a function that takes a state and rotates the top 3 items of the appropriate
  stack of the state.
  """
  def exec_rot(state) do
    if not(Enum.empty?(Enum.drop(Enum.drop(state[:exec], 1), 1))) do
      first = stack_ref(:exec, 0, state)
      second = stack_ref(:exec, 1, state)
      third = stack_ref(:exec, 2, state)
      push_item(third, :exec, push_item(first, :exec, push_item(second, :exec, pop_item(:exec, pop_item(:exec, pop_item(:exec, state))))))
    else
      state
    end
  end

  @doc "Returns a function that empties the stack of the given state."
  def exec_flush(state), do: Map.merge(state, %{:exec => []})

  @doc """
  Returns a function that compares the top two items of the appropriate stack of
  the given state.
  """
  def exec_eq(state) do
    if not(Enum.empty?(Enum.drop(state[:exec], 1))) do
      first = stack_ref(:exec, 0, state)
      second = stack_ref(:exec, 1, state)
      push_item(first == second, :boolean, pop_item(:exec, pop_item(:exec, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the depth of the appropriate stack of the
  given state.
  """
  def exec_stackdepth(state) do
    state[:exec] |> length |> push_item(:integer, state)
  end

  @doc """
  Returns a function that yanks an item from deep in the specified stack,
  using the top integer to indicate how deep.
  """
  def exec_yank(state) do
    if not(Enum.empty?(state[:exec])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index = raw_index |> min(length(with_index_popped[:exec]) - 1) |> max(0)
      item = stack_ref(:exec, actual_index, with_index_popped)
      stk = with_index_popped[:exec]
      with_item_pulled = Map.merge(with_index_popped, %{:exec => Enum.concat(Enum.take(stk, actual_index), Enum.drop(Enum.drop(stk, actual_index), 1))})
      push_item(item, :exec, with_item_pulled)
    else
      state
    end
  end

  @doc """
  Returns a function that yanks a copy of an item from deep in the specified stack,
  using the top integer to indicate how deep.
  """
  def exec_yankdup(state) do
    if not(Enum.empty?(state[:exec])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index = raw_index |> min(length(with_index_popped[:exec]) - 1) |> max(0)
      item = stack_ref(:exec, actual_index, with_index_popped)
      push_item(item, :exec, with_index_popped)
    else
      state
    end
  end

  @doc """
  Returns a function that shoves an item deep in the specified stack, using the top
  integer to indicate how deep.
  """
  def exec_shove(state) do
    if not(Enum.empty?(state[:exec])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      item = top_item(:exec, with_index_popped)
      with_args_popped = pop_item(:exec, with_index_popped)
      actual_index = raw_index |> min(length(with_args_popped[:exec])) |> max(0)
      stk = with_args_popped[:exec]
      Map.merge(with_args_popped, %{:exec => Enum.concat(Enum.take(stk, actual_index), [item], Enum.drop(stk, actual_index))})
    else
      state
    end
  end

  @doc "Returns a function that takes a state and tells whether that stack is empty."
  def exec_empty(state), do: push_item(Enum.empty?(state[:exec]), :boolean, state)

  ### INTEGER
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
      with_item_pulled = Map.merge(with_index_popped, %{:integer => Enum.concat(Enum.take(stk, actual_index), Enum.drop(Enum.drop(stk, actual_index), 1))})
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

  ### FLOAT
  @doc "Returns a function that takes a state and pops the appropriate stack of the state."
  def float_pop(state), do: pop_item(:float, state)

  @doc """
  Returns a function that takes a state and duplicates the top item of the appropriate
  stack of the state.
  """
  def float_dup(state) do
    if Enum.empty?(state[:float]) do
      state
    else
      :float |> top_item(state) |> push_item(:float, state)
    end
  end

  @doc """
  Returns a function that takes a state and swaps the top 2 items of the appropriate
  stack of the state.
  """
  def float_swap(state) do
    if not(Enum.empty?(Enum.drop(state[:float], 1))) do
      first_item = stack_ref(:float, 0, state)
      second_item = stack_ref(:float, 1, state)
      push_item(second_item, :float, push_item(first_item, :float, pop_item(:float, pop_item(:float, state))))
    else
      state
    end
  end

  @doc """
  Returns a function that takes a state and rotates the top 3 items of the appropriate
  stack of the state.
  """
  def float_rot(state) do
    if not(Enum.empty?(Enum.drop(Enum.drop(state[:float], 1), 1))) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      third = stack_ref(:float, 2, state)
      push_item(third, :float, push_item(first, :float, push_item(second, :float, pop_item(:float, pop_item(:float, pop_item(:float, state))))))
    else
      state
    end
  end

  @doc "Returns a function that empties the stack of the given state."
  def float_flush(state), do: Map.merge(state, %{:float => []})

  @doc """
  Returns a function that compares the top two items of the appropriate stack of
  the given state.
  """
  def float_eq(state) do
    if not(Enum.empty?(Enum.drop(state[:float], 1))) do
      first = stack_ref(:float, 0, state)
      second = stack_ref(:float, 1, state)
      push_item(first == second, :float, pop_item(:float, pop_item(:float, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the depth of the appropriate stack of the
  given state.
  """
  def float_stackdepth(state) do
    state[:float] |> length |> push_item(:integer, state)
  end

  @doc """
  Returns a function that yanks an item from deep in the specified stack,
  using the top integer to indicate how deep.
  """
  def float_yank(state) do
    if not(Enum.empty?(state[:float])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index = raw_index |> min(length(with_index_popped[:float]) - 1) |> max(0)
      item = stack_ref(:float, actual_index, with_index_popped)
      stk = with_index_popped[:float]
      with_item_pulled = Map.merge(with_index_popped, %{:float => Enum.concat(Enum.take(stk, actual_index), Enum.drop(Enum.drop(stk, actual_index), 1))})
      push_item(item, :float, with_item_pulled)
    else
      state
    end
  end

  @doc """
  Returns a function that yanks a copy of an item from deep in the specified stack,
  using the top integer to indicate how deep.
  """
  def float_yankdup(state) do
    if not(Enum.empty?(state[:float])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index = raw_index |> min(length(with_index_popped[:float]) - 1) |> max(0)
      item = stack_ref(:float, actual_index, with_index_popped)
      push_item(item, :float, with_index_popped)
    else
      state
    end
  end

  @doc """
  Returns a function that shoves an item deep in the specified stack, using the top
  integer to indicate how deep.
  """
  def float_shove(state) do
    if not(Enum.empty?(state[:float])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      item = top_item(:float, with_index_popped)
      with_args_popped = pop_item(:float, with_index_popped)
      actual_index = raw_index |> min(length(with_args_popped[:float])) |> max(0)
      stk = with_args_popped[:float]
      Map.merge(with_args_popped, %{:float => Enum.concat(Enum.take(stk, actual_index), [item], Enum.drop(stk, actual_index))})
    else
      state
    end
  end

  @doc "Returns a function that takes a state and tells whether that stack is empty."
  def float_empty(state), do: push_item(Enum.empty?(state[:float]), :float, state)

  ### CODE
  @doc "Returns a function that takes a state and pops the appropriate stack of the state."
  def code_pop(state), do: pop_item(:code, state)

  @doc """
  Returns a function that takes a state and duplicates the top item of the appropriate
  stack of the state.
  """
  def code_dup(state) do
    if Enum.empty?(state[:code]) do
      state
    else
      :code |> top_item(state) |> push_item(:code, state)
    end
  end

  @doc """
  Returns a function that takes a state and swaps the top 2 items of the appropriate
  stack of the state.
  """
  def code_swap(state) do
    if not(Enum.empty?(Enum.drop(state[:code], 1))) do
      first_item = stack_ref(:code, 0, state)
      second_item = stack_ref(:code, 1, state)
      push_item(second_item, :code, push_item(first_item, :code, pop_item(:code, pop_item(:code, state))))
    else
      state
    end
  end

  @doc """
  Returns a function that takes a state and rotates the top 3 items of the appropriate
  stack of the state.
  """
  def code_rot(state) do
    if not(Enum.empty?(Enum.drop(Enum.drop(state[:code], 1), 1))) do
      first = stack_ref(:code, 0, state)
      second = stack_ref(:code, 1, state)
      third = stack_ref(:code, 2, state)
      push_item(third, :code, push_item(first, :code, push_item(second, :code, pop_item(:code, pop_item(:code, pop_item(:code, state))))))
    else
      state
    end
  end

  @doc "Returns a function that empties the stack of the given state."
  def code_flush(state), do: Map.merge(state, %{:code => []})

  @doc """
  Returns a function that compares the top two items of the appropriate stack of
  the given state.
  """
  def code_eq(state) do
    if not(Enum.empty?(Enum.drop(state[:code], 1))) do
      first = stack_ref(:code, 0, state)
      second = stack_ref(:code, 1, state)
      push_item(first == second, :boolean, pop_item(:code, pop_item(:code, state)))
    else
      state
    end
  end

  @doc """
  Returns a function that pushes the depth of the appropriate stack of the
  given state.
  """
  def code_stackdepth(state) do
    state[:code] |> length |> push_item(:integer, state)
  end

  @doc """
  Returns a function that yanks an item from deep in the specified stack,
  using the top integer to indicate how deep.
  """
  def code_yank(state) do
    if not(Enum.empty?(state[:code])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index = raw_index |> min(length(with_index_popped[:code]) - 1) |> max(0)
      item = stack_ref(:code, actual_index, with_index_popped)
      stk = with_index_popped[:code]
      with_item_pulled = Map.merge(with_index_popped, %{:code => Enum.concat(Enum.take(stk, actual_index), Enum.drop(Enum.drop(stk, actual_index), 1))})
      push_item(item, :code, with_item_pulled)
    else
      state
    end
  end

  @doc """
  Returns a function that yanks a copy of an item from deep in the specified stack,
  using the top integer to indicate how deep.
  """
  def code_yankdup(state) do
    if not(Enum.empty?(state[:code])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index = raw_index |> min(length(with_index_popped[:code]) - 1) |> max(0)
      item = stack_ref(:code, actual_index, with_index_popped)
      push_item(item, :code, with_index_popped)
    else
      state
    end
  end

  @doc """
  Returns a function that shoves an item deep in the specified stack, using the top
  integer to indicate how deep.
  """
  def code_shove(state) do
    if not(Enum.empty?(state[:code])) and not(Enum.empty?(state[:integer])) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      item = top_item(:code, with_index_popped)
      with_args_popped = pop_item(:code, with_index_popped)
      actual_index = raw_index |> min(length(with_args_popped[:code])) |> max(0)
      stk = with_args_popped[:code]
      Map.merge(with_args_popped, %{:code => Enum.concat(Enum.take(stk, actual_index), [item], Enum.drop(stk, actual_index))})
    else
      state
    end
  end

  @doc "Returns a function that takes a state and tells whether that stack is empty."
  def code_empty(state), do: push_item(Enum.empty?(state[:code]), :boolean, state)

  ### BOOLEAN
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
      with_item_pulled = Map.merge(with_index_popped, %{:boolean => Enum.concat(Enum.take(stk, actual_index), Enum.drop(Enum.drop(stk, actual_index), 1))})
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

  ### STRING

  ### CHAR
end
