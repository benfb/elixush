defmodule Elixush.Instructions.Common do
  @moduledoc "Common instructions that operate on many stacks."
  import Elixush.PushState

  @doc "Takes a type and a state and pops the appropriate stack of the state."
  def popper(type, state), do: pop_item(type, state)

  @doc """
  Takes a type and a state and duplicates the top item of the appropriate
  stack of the state.
  """
  defp duper(type, state) do
    if Enum.empty?(state[type]), do: state, else: type |> top_item(state) |> push_item(type, state)
  end

  @doc """
  Takes a type and a state and swaps the top 2 items of the appropriate
  stack of the state.
  """
  def swapper(type, state) do
    if not(Enum.empty?(Enum.drop(state[type], 1))) do
      first_item = stack_ref(type, 0, state)
      second_item = stack_ref(type, 1, state)
      push_item(second_item, type, push_item(first_item, type, pop_item(type, pop_item(type, state))))
    else
      state
    end
  end

  @doc """
  Takes a type and a state and rotates the top 3 items of the appropriate
  stack of the state.
  """
  def rotter(type, state) do
    if not(Enum.empty?(Enum.drop(Enum.drop(state[type], 1), 1))) do
      first = stack_ref(type, 0, state)
      second = stack_ref(type, 1, state)
      third = stack_ref(type, 2, state)
      push_item(third, type, push_item(first, type, push_item(second, type, pop_item(type, pop_item(type, pop_item(type, state))))))
    else
      state
    end
  end

  @doc "Empties the type stack of the given state."
  def flusher(type, state), do: Map.merge(state, %{type => []})

  @doc "Compares the top two items of the type stack of the given state."
  def eqer(type, state) do
    if not(Enum.empty?(Enum.drop(state[type], 1))) do
      first = stack_ref(type, 0, state)
      second = stack_ref(type, 1, state)
      push_item(first == second, :boolean, pop_item(type, pop_item(type, state)))
    else
      state
    end
  end

  @doc "Pushes the depth of the type stack of the given state."
  def stackdepther(type, state), do: state[type] |> length |> push_item(:integer, state)

  @doc """
  Yanks an item from deep in the specified stack, using the top integer
  to indicate how deep.
  """
  def yanker(type, state) do
    if (type == :integer and not(Enum.empty?(Enum.drop(state[type], 1)))) or (type != :integer and (not(Enum.empty?(state[type])) and not(Enum.empty?(state[:integer])))) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index = raw_index |> min(length(with_index_popped[type]) - 1) |> max(0)
      item = stack_ref(type, actual_index, with_index_popped)
      stk = with_index_popped[type]
      with_item_pulled = Map.merge(with_index_popped, %{type => Enum.concat(Enum.take(stk, actual_index), Enum.drop(Enum.drop(stk, actual_index), 1))})
      push_item(item, type, with_item_pulled)
    else
      state
    end
  end

  @doc """
  Yanks a copy of an item from deep in the specified stack, using the top
  integer to indicate how deep.
  """
  def yankduper(type, state) do
    if (type == :integer and not(Enum.empty?(Enum.drop(state[type], 1)))) or (type != :integer and (not(Enum.empty?(state[type])) and not(Enum.empty?(state[:integer])))) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      actual_index =
        raw_index |> min(length(with_index_popped[type]) - 1) |> max(0)
      item = stack_ref(type, actual_index, with_index_popped)
      push_item(item, type, with_index_popped)
    else
      state
    end
  end

  @doc """
  Shoves an item deep in the specified stack, using the top integer to
  indicate how deep.
  """
  def shover(type, state) do
    if (type == :integer and not(Enum.empty?(Enum.drop(state[type], 1)))) or (type != :integer and (not(Enum.empty?(state[type])) and not(Enum.empty?(state[:integer])))) do
      raw_index = stack_ref(:integer, 0, state)
      with_index_popped = pop_item(:integer, state)
      item = top_item(type, with_index_popped)
      with_args_popped = pop_item(type, with_index_popped)
      actual_index = raw_index |> min(length(with_args_popped[type])) |> max(0)
      stk = with_args_popped[type]
      Map.merge(with_args_popped, %{type => Enum.concat(Enum.take(stk, actual_index), Enum.concat([item], Enum.drop(stk, actual_index)))})
    else
      state
    end
  end

  @doc "Takes a type and a state and tells whether that stack is empty."
  def emptyer(type, state), do: push_item(Enum.empty?(state[type]), :boolean, state)

  ### EXEC
  def exec_pop(state), do: popper(:exec, state)
  def exec_dup(state), do: duper(:exec, state)
  def exec_swap(state), do: swapper(:exec, state)
  def exec_rot(state), do: rotter(:exec, state)
  def exec_flush(state), do: flusher(:exec, state)
  def exec_eq(state), do: eqer(:exec, state)
  def exec_stackdepth(state), do: stackdepther(:exec, state)
  def exec_yank(state), do: yanker(:exec, state)
  def exec_yankdup(state), do: yankduper(:exec, state)
  def exec_shove(state), do: shover(:exec, state)
  def exec_empty(state), do: emptyer(:exec, state)

  ### INTEGER
  def integer_pop(state), do: popper(:integer, state)
  def integer_dup(state), do: duper(:integer, state)
  def integer_swap(state), do: swapper(:integer, state)
  def integer_rot(state), do: rotter(:integer, state)
  def integer_flush(state), do: flusher(:integer, state)
  def integer_eq(state), do: eqer(:integer, state)
  def integer_stackdepth(state), do: stackdepther(:integer, state)
  def integer_yank(state), do: yanker(:integer, state)
  def integer_yankdup(state), do: yankduper(:integer, state)
  def integer_shove(state), do: shover(:integer, state)
  def integer_empty(state), do: emptyer(:integer, state)

  ### FLOAT
  def float_pop(state), do: popper(:float, state)
  def float_dup(state), do: duper(:float, state)
  def float_swap(state), do: swapper(:float, state)
  def float_rot(state), do: rotter(:float, state)
  def float_flush(state), do: flusher(:float, state)
  def float_eq(state), do: eqer(:float, state)
  def float_stackdepth(state), do: stackdepther(:float, state)
  def float_yank(state), do: yanker(:float, state)
  def float_yankdup(state), do: yankduper(:float, state)
  def float_shove(state), do: shover(:float, state)
  def float_empty(state), do: emptyer(:float, state)

  ### CODE
  def code_pop(state), do: popper(:code, state)
  def code_dup(state), do: duper(:code, state)
  def code_swap(state), do: swapper(:code, state)
  def code_rot(state), do: rotter(:code, state)
  def code_flush(state), do: flusher(:code, state)
  def code_eq(state), do: eqer(:code, state)
  def code_stackdepth(state), do: stackdepther(:code, state)
  def code_yank(state), do: yanker(:code, state)
  def code_yankdup(state), do: yankduper(:code, state)
  def code_shove(state), do: shover(:code, state)
  def code_empty(state), do: emptyer(:code, state)

  ### BOOLEAN
  def boolean_pop(state), do: popper(:boolean, state)
  def boolean_dup(state), do: duper(:boolean, state)
  def boolean_swap(state), do: swapper(:boolean, state)
  def boolean_rot(state), do: rotter(:boolean, state)
  def boolean_flush(state), do: flusher(:boolean, state)
  def boolean_eq(state), do: eqer(:boolean, state)
  def boolean_stackdepth(state), do: stackdepther(:boolean, state)
  def boolean_yank(state), do: yanker(:boolean, state)
  def boolean_yankdup(state), do: yankduper(:boolean, state)
  def boolean_shove(state), do: shover(:boolean, state)
  def boolean_empty(state), do: emptyer(:boolean, state)

  ### STRING
  def string_pop(state), do: popper(:string, state)
  def string_dup(state), do: duper(:string, state)
  def string_swap(state), do: swapper(:string, state)
  def string_rot(state), do: rotter(:string, state)
  def string_flush(state), do: flusher(:string, state)
  def string_eq(state), do: eqer(:string, state)
  def string_stackdepth(state), do: stackdepther(:string, state)
  def string_yank(state), do: yanker(:string, state)
  def string_yankdup(state), do: yankduper(:string, state)
  def string_shove(state), do: shover(:string, state)
  def string_empty(state), do: emptyer(:string, state)

  ### CHAR
  def char_pop(state), do: popper(:char, state)
  def char_dup(state), do: duper(:char, state)
  def char_swap(state), do: swapper(:char, state)
  def char_rot(state), do: rotter(:char, state)
  def char_flush(state), do: flusher(:char, state)
  def char_eq(state), do: eqer(:char, state)
  def char_stackdepth(state), do: stackdepther(:char, state)
  def char_yank(state), do: yanker(:char, state)
  def char_yankdup(state), do: yankduper(:char, state)
  def char_shove(state), do: shover(:char, state)
  def char_empty(state), do: emptyer(:char, state)
end
