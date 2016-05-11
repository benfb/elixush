defmodule Elixush.Instructions.Vectors do
  import Elixush.PushState
  import Elixush.Instructions.Common
  import Elixush.Globals.Agent, only: [get_globals: 1]

  def vector_integer_pop(state), do: popper(:vector_integer, state)
  def vector_float_pop(state), do: popper(:vector_float, state)
  def vector_boolean_pop(state), do: popper(:vector_boolean, state)
  def vector_string_pop(state), do: popper(:vector_string, state)

  def vector_integer_dup(state), do: duper(:vector_integer, state)
  def vector_float_dup(state), do: duper(:vector_float, state)
  def vector_boolean_dup(state), do: duper(:vector_boolean, state)
  def vector_string_dup(state), do: duper(:vector_string, state)

  def vector_integer_swap(state), do: swapper(:vector_integer, state)
  def vector_float_swap(state), do: swapper(:vector_float, state)
  def vector_boolean_swap(state), do: swapper(:vector_boolean, state)
  def vector_string_swap(state), do: swapper(:vector_string, state)

  def vector_integer_rot(state), do: rotter(:vector_integer, state)
  def vector_float_rot(state), do: rotter(:vector_float, state)
  def vector_boolean_rot(state), do: rotter(:vector_boolean, state)
  def vector_string_rot(state), do: rotter(:vector_string, state)

  def vector_integer_flush(state), do: flusher(:vector_integer, state)
  def vector_float_flush(state), do: flusher(:vector_float, state)
  def vector_boolean_flush(state), do: flusher(:vector_boolean, state)
  def vector_string_flush(state), do: flusher(:vector_string, state)

  def vector_integer_eq(state), do: eqer(:vector_integer, state)
  def vector_float_eq(state), do: eqer(:vector_float, state)
  def vector_boolean_eq(state), do: eqer(:vector_boolean, state)
  def vector_string_eq(state), do: eqer(:vector_string, state)

  def vector_integer_stackdepth(state), do: stackdepther(:vector_integer, state)
  def vector_float_stackdepth(state), do: stackdepther(:vector_float, state)
  def vector_boolean_stackdepth(state), do: stackdepther(:vector_boolean, state)
  def vector_string_stackdepth(state), do: stackdepther(:vector_string, state)

  def vector_integer_yank(state), do: yanker(:vector_integer, state)
  def vector_float_yank(state), do: yanker(:vector_float, state)
  def vector_boolean_yank(state), do: yanker(:vector_boolean, state)
  def vector_string_yank(state), do: yanker(:vector_string, state)

  def vector_integer_yankdup(state), do: yankduper(:vector_integer, state)
  def vector_float_yankdup(state), do: yankduper(:vector_float, state)
  def vector_boolean_yankdup(state), do: yankduper(:vector_boolean, state)
  def vector_string_yankdup(state), do: yankduper(:vector_string, state)

  def vector_integer_shove(state), do: shover(:vector_integer, state)
  def vector_float_shove(state), do: shover(:vector_float, state)
  def vector_boolean_shove(state), do: shover(:vector_boolean, state)
  def vector_string_shove(state), do: shover(:vector_string, state)

  def vector_integer_empty(state), do: emptyer(:vector_integer, state)
  def vector_float_empty(state), do: emptyer(:vector_float, state)
  def vector_boolean_empty(state), do: emptyer(:vector_boolean, state)
  def vector_string_empty(state), do: emptyer(:vector_string, state)

  ### common instructions for vectors

  @doc "Takes a type and a state and concats two vectors on the type stack."
  def concater(type, state) do
    if not(Enum.empty?(Enum.drop(state[type], 1))) do
      first_item = stack_ref(type, 0, state)
      second_item = stack_ref(type, 1, state)
      if get_globals(:max_vector_length) >= Enum.count(first_item) + Enum.count(second_item) do
        Enum.concat(second_item, first_item) |> push_item(type, pop_item(type, pop_item(type, state)))
      else
        state
      end
    else
      state
    end
  end

  def vector_integer_concat(state), do: concater(:vector_integer, state)
  def vector_float_concat(state), do: concater(:vector_float, state)
  def vector_boolean_concat(state), do: concater(:vector_boolean, state)
  def vector_string_concat(state), do: concater(:vector_string, state)
end
