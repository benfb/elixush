defmodule Elixush.Instructions.Vectors do
  @moduledoc "Instructions that operate on various vector stacks."
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
        second_item
        |> Enum.concat(first_item)
        |> push_item(type, pop_item(type, pop_item(type, state)))
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

  @doc """
  Takes a vec_type, a lit_type, and a state and conj's an item onto the
  type stack.
  """
  def conjer(vec_type, lit_type, state) do
    if not(Enum.empty?(state[vec_type])) and not(Enum.empty?(state[lit_type])) do
      result = lit_type
               |> top_item(state)
               |> List.insert_at(-1, top_item(vec_type, state))
      if get_globals(:max_vector_length) >= Enum.count(result) do
        result
        |> push_item(vec_type, pop_item(lit_type, pop_item(vec_type, state)))
      else
        state
      end
    else
      state
    end
  end

  def vector_integer_conj(state), do: conjer(:vector_integer, :integer, state)
  def vector_float_conj(state), do: conjer(:vector_float, :float, state)
  def vector_boolean_conj(state), do: conjer(:vector_boolean, :boolean, state)
  def vector_string_conj(state), do: conjer(:vector_string, :string, state)

  @doc """
  Takes a type and a state and takes the first N items from the type stack,
  where N is from the integer stack.
  """
  def taker(type, state) do
    if not(Enum.empty?(state[type])) and not(Enum.empty?(state[:integer])) do
      type
      |> top_item(state)
      |> Enum.take(top_item(:integer, state))
      |> push_item(type, pop_item(type, pop_item(:integer, state)))
    else
      state
    end
  end

  def vector_integer_take(state), do: taker(:vector_integer, state)
  def vector_float_take(state), do: taker(:vector_float, state)
  def vector_boolean_take(state), do: taker(:vector_boolean, state)
  def vector_string_take(state), do: taker(:vector_string, state)

  @doc """
  Takes a type and a state and takes the subvec of the top item on the
  type stack.
  """
  def subvecer(type, state) do
    if not(Enum.empty?(state[type])) and not(Enum.empty?(Enum.drop(state[:integer], 1))) do
      vect = top_item(type, state)
      first_index = vect
                    |> Enum.count
                    |> min(max(0, stack_ref(:integer, 1, state)))
      second_index = vect
                     |> Enum.count
                     |> min(max(first_index, stack_ref(:integer, 0, state)))
      vect
      |> Enum.slice(first_index, second_index - first_index)
      |> push_item(type, pop_item(type, pop_item(:integer, pop_item(:integer, state))))
    else
      state
    end
  end

  def vector_integer_subvec(state), do: subvecer(:vector_integer, state)
  def vector_float_subvec(state), do: subvecer(:vector_float, state)
  def vector_boolean_subvec(state), do: subvecer(:vector_boolean, state)
  def vector_string_subvec(state), do: subvecer(:vector_string, state)

  @doc "Takes a type and a state and gets the first item from the type stack."
  def firster(type, lit_type, state) do
    if not(Enum.empty?(state[type])) and not(Enum.empty?(List.first(state[type]))) do
      type
      |> top_item(state)
      |> List.first
      |> push_item(lit_type, pop_item(type, state))
    else
      state
    end
  end

  def vector_integer_first(state), do: firster(:vector_integer, :integer, state)
  def vector_float_first(state), do: firster(:vector_float, :float, state)
  def vector_boolean_first(state), do: firster(:vector_boolean, :boolean, state)
  def vector_string_first(state), do: firster(:vector_string, :string, state)

  @doc "Takes a type and a state and gets the last item from the type stack."
  def laster(type, lit_type, state) do
    if not(Enum.empty?(state[type])) and not(Enum.empty?(List.first(state[type]))) do
      type
      |> top_item(state)
      |> List.last
      |> push_item(lit_type, pop_item(type, state))
    else
      state
    end
  end

  def vector_integer_last(state), do: laster(:vector_integer, :integer, state)
  def vector_float_last(state), do: laster(:vector_float, :float, state)
  def vector_boolean_last(state), do: laster(:vector_boolean, :boolean, state)
  def vector_string_last(state), do: laster(:vector_string, :string, state)

  @doc "Takes a type and a state and gets the nth item from the type stack."
  def nther(type, lit_type, state) do
    if (not(Enum.empty?(state[type])) and not(Enum.empty?(List.first(state[type])))) and not(Enum.empty?(state[:integr])) do
      vect = stack_ref(type, 0, state)
      index = rem(stack_ref(:integer, 0, state), Enum.count(vect))
      vect |> Enum.at(index) |> push_item(lit_type, pop_item(:integer, pop_item(type, state)))
    else
      state
    end
  end

  def vector_integer_nth(state), do: nther(:vector_integer, :integer, state)
  def vector_float_nth(state), do: nther(:vector_float, :float, state)
  def vector_boolean_nth(state), do: nther(:vector_boolean, :boolean, state)
  def vector_string_nth(state), do: nther(:vector_string, :string, state)

  @doc """
  Takes a type and a state and takes the rest of the top item on the type stack.
  """
  def rester(type, state) do
    if (not(Enum.empty?(state[type]))) do
      type |> top_item(state) |> Enum.drop(1) |> push_item(type, pop_item(type, state))
    else
      state
    end
  end

  def vector_integer_rest(state), do: rester(:vector_integer, state)
  def vector_float_rest(state), do: rester(:vector_float, state)
  def vector_boolean_rest(state), do: rester(:vector_boolean, state)
  def vector_string_rest(state), do: rester(:vector_string, state)

  @doc """
  Takes a type and a state and takes the butlast of the top item on the
  type stack.
  """
  def butlaster(type, state) do
    if (not(Enum.empty?(state[type]))) do
      type |> top_item(state) |> Enum.drop(-1) |> push_item(type, pop_item(type, state))
    else
      state
    end
  end

  def vector_integer_butlast(state), do: butlaster(:vector_integer, state)
  def vector_float_butlast(state), do: butlaster(:vector_float, state)
  def vector_boolean_butlast(state), do: butlaster(:vector_boolean, state)
  def vector_string_butlast(state), do: butlaster(:vector_string, state)

  @doc """
  Takes a type and a state and takes the length of the top item on the
  type stack.
  """
  def lengther(type, state) do
    if (not(Enum.empty?(state[type]))) do
      type |> top_item(state) |> Enum.count |> push_item(:integer, pop_item(type, state))
    else
      state
    end
  end

  def vector_integer_length(state), do: lengther(:vector_integer, state)
  def vector_float_length(state), do: lengther(:vector_float, state)
  def vector_boolean_length(state), do: lengther(:vector_boolean, state)
  def vector_string_length(state), do: lengther(:vector_string, state)

  @doc """
  Takes a type and a state and takes the reverse of the top item on the
  type stack.
  """
  def reverser(type, state) do
    if (not(Enum.empty?(state[type]))) do
      type |> top_item(state) |> Enum.reverse |> push_item(type, pop_item(type, state))
    else
      state
    end
  end

  def vector_integer_reverse(state), do: reverser(:vector_integer, state)
  def vector_float_reverse(state), do: reverser(:vector_float, state)
  def vector_boolean_reverse(state), do: reverser(:vector_boolean, state)
  def vector_string_reverse(state), do: reverser(:vector_string, state)

  @doc """
  Takes a type and a state and pushes every item from the first vector
  onto the appropriate stack.
  """
  def pushaller(type, lit_type, state) do
    if Enum.empty?(state[type]) do
      state
    else
      loop = fn(f, lit_list, loop_state) ->
        if Enum.empty?(lit_list) do
          loop_state
        else
          f.(f, Enum.drop(lit_list, 1), push_item(List.first(lit_list), lit_type, loop_state))
        end
      end
      loop.(loop, Enum.reverse(top_item(type, state)), pop_item(type, state))
    end
  end

  def vector_integer_pushall(state), do: pushaller(:vector_integer, :integer, state)
  def vector_float_pushall(state), do: pushaller(:vector_float, :float, state)
  def vector_boolean_pushall(state), do: pushaller(:vector_boolean, :boolean, state)
  def vector_string_pushall(state), do: pushaller(:vector_string, :string, state)

  @doc """
  Takes a type and a state and pushes a boolean of whether the top vector
  is empty.
  """
  def emptyvectorer(type, state) do
    if (not(Enum.empty?(state[type]))) do
      type |> top_item(state) |> Enum.empty? |> push_item(:boolean, pop_item(type, state))
    else
      state
    end
  end

  def vector_integer_emptyvector(state), do: emptyvectorer(:vector_integer, state)
  def vector_float_emptyvector(state), do: emptyvectorer(:vector_float, state)
  def vector_boolean_emptyvector(state), do: emptyvectorer(:vector_boolean, state)
  def vector_string_emptyvector(state), do: emptyvectorer(:vector_string, state)

  @doc """
  Takes a type and a state and tells whether the top lit_type item is in the top
  type vector.
  """
  def containser(type, lit_type, state) do
    if Enum.empty?(state[type]) or Enum.empty?(state[lit_type]) do
      state
    else
      item = top_item(lit_type, state)
      vect = top_item(type, state)
      vect |> Enum.member?(item) |> push_item(:boolean, pop_item(lit_type, pop_item(type, state)))
    end
  end

  def vector_integer_contains(state), do: containser(:vector_integer, :integer, state)
  def vector_float_contains(state), do: containser(:vector_float, :float, state)
  def vector_boolean_contains(state), do: containser(:vector_boolean, :boolean, state)
  def vector_string_contains(state), do: containser(:vector_string, :string, state)

  @doc """
  Takes a type and a state and finds the index of the top lit_type item
  in the top type vector.
  """
  def indexofer(type, lit_type, state) do
    if Enum.empty?(state[type]) or Enum.empty?(state[lit_type]) do
      state
    else
      item = top_item(lit_type, state)
      vect = top_item(type, state)
      result = Enum.find_index(vect, item)
      result
      |> (fn(x) -> x or -1 end).()
      |> push_item(:integer, pop_item(lit_type, pop_item(type, state)))
    end
  end

  def vector_integer_indexof(state), do: indexofer(:vector_integer, :integer, state)
  def vector_float_indexof(state), do: indexofer(:vector_float, :float, state)
  def vector_boolean_indexof(state), do: indexofer(:vector_boolean, :boolean, state)
  def vector_string_indexof(state), do: indexofer(:vector_string, :string, state)

  @doc """
  Takes a type and a state and counts the occurrences of the top lit_type item
  in the top type vector.
  """
  def occurrencesofer(type, lit_type, state) do
    if Enum.empty?(state[type]) or Enum.empty?(state[lit_type]) do
      state
    else
      item = top_item(lit_type, state)
      vect = top_item(type, state)
      result = vect |> Enum.filter(&(&1 == item)) |> Enum.count
      result |> push_item(:integer, pop_item(lit_type, pop_item(type, state)))
    end
  end

  def vector_integer_occurrencesof(state), do: occurrencesofer(:vector_integer, :integer, state)
  def vector_float_occurrencesof(state), do: occurrencesofer(:vector_float, :float, state)
  def vector_boolean_occurrencesof(state), do: occurrencesofer(:vector_boolean, :boolean, state)
  def vector_string_occurrencesof(state), do: occurrencesofer(:vector_string, :string, state)

  @doc """
  Takes a type and a state and replaces, in the top type vector, item at index
  (from integer stack) with the first lit_type item.
  """
  def seter(type, lit_type, state) do
    if (Enum.empty?(state[type]) or Enum.empty?(state[lit_type])) or (Enum.empty?(state[:integer]) or (lit_type == :integer and Enum.empty?(Enum.drop(state[:integer], 1)))) do
      state
    else
      vect = top_item(type, state)
      item = if lit_type == :integer, do: stack_ref(:integer, 1, state), else: top_item(lit_type, state)
      index = if Enum.empty?(vect), do: 0, else: rem(top_item(:integer, state), Enum.count(vect))
      result = if Enum.empty?(vect), do: vect, else: List.replace_at(vect, index, item)
      result
      |> push_item(type, pop_item(lit_type, pop_item(:integer, pop_item(type, state))))
    end
  end

  def vector_integer_set(state), do: seter(:vector_integer, :integer, state)
  def vector_float_set(state), do: seter(:vector_float, :float, state)
  def vector_boolean_set(state), do: seter(:vector_boolean, :boolean, state)
  def vector_string_set(state), do: seter(:vector_string, :string, state)

  @doc """
  Takes a type and a state and replaces all occurrences of the second lit_type
  item with the first lit_type item in the top type vector.
  """
  def replaceer(type, lit_type, state) do
    if Enum.empty?(state[type]) or Enum.empty?(Enum.drop(state[lit_type], 1)) do
      state
    else
      replace_with = stack_ref(lit_type, 0, state)
      to_replace = stack_ref(lit_type, 1, state)
      vect = top_item(type, state)
      result = vect |> Enum.map(&(if &1 == to_replace, do: replace_with, else: &1))
      result
      |> push_item(type, pop_item(lit_type, pop_item(lit_type, pop_item(type, state))))
    end
  end

  def vector_integer_replace(state), do: replaceer(:vector_integer, :integer, state)
  def vector_float_replace(state), do: replaceer(:vector_float, :float, state)
  def vector_boolean_replace(state), do: replaceer(:vector_boolean, :boolean, state)
  def vector_string_replace(state), do: replaceer(:vector_string, :string, state)

  @doc """
  Takes a type and a state and replaces the first occurrence of the second
  lit_type item with the first lit_type item in the top type vector.
  """
  def replacefirster(type, lit_type, state) do
    if Enum.empty?(state[type]) or Enum.empty?(Enum.drop(state[lit_type], 1)) do
      state
    else
      replace_with = stack_ref(lit_type, 0, state)
      to_replace = stack_ref(lit_type, 1, state)
      vect = top_item(type, state)
      index = vect |> Enum.find(&(&1 == to_replace))
      index = if index == nil, do: -1, else: index
      result = List.replace_at(vect, index, replace_with)
      result |> push_item(type, pop_item(lit_type, pop_item(lit_type, pop_item(type, state))))
    end
  end

  def vector_integer_replacefirst(state), do: replacefirster(:vector_integer, :integer, state)
  def vector_float_replacefirst(state), do: replacefirster(:vector_float, :float, state)
  def vector_boolean_replacefirst(state), do: replacefirster(:vector_boolean, :boolean, state)
  def vector_string_replacefirst(state), do: replacefirster(:vector_string, :string, state)

  @doc """
  Takes a type and a state and removes all occurrences of the first lit_type
  item in the top type vector.
  """
  def removeer(type, lit_type, state) do
    if Enum.empty?(state[type]) or Enum.empty?(state[lit_type]) do
      state
    else
      vect = top_item(type, state)
      item = top_item(lit_type, state)
      result = vect |> Enum.filter(&(&1 != top_item(lit_type, state)))
      result |> push_item(type, pop_item(lit_type, pop_item(type, state)))
    end
  end

  def vector_integer_remove(state), do: removeer(:vector_integer, :integer, state)
  def vector_float_remove(state), do: removeer(:vector_float, :float, state)
  def vector_boolean_remove(state), do: removeer(:vector_boolean, :boolean, state)
  def vector_string_remove(state), do: removeer(:vector_string, :string, state)

  @doc """
  Takes a type and a state and iterates over the type vector using the code on
  the exec stack. If the vector isn't empty, expands to:
  ((first vector) (top-item :exec state) (rest vector) exec_do*vector_type (top-item :exec state) rest_of_program)
  """
  def iterateer(type, lit_type, instr, state) do
    if Enum.empty?(state[type]) or Enum.empty?(state[:exec]) do
      state
    else
      vect = top_item(type, state)
      cond do
        Enum.empty?(vect) -> pop_item(:exec, pop_item(type, state))
        Enum.empty?(Enum.drop(vect, 1)) -> push_item(List.first(vect), lit_type, pop_item(type, state))
        true -> push_item(List.first(vect), lit_type, push_item(top_item(:exec, state), :exec, push_item(Enum.drop(vect, 1), :exec, push_item(instr, :exec, pop_item(type, state)))))
      end
    end
  end

  def exec_do_star_vector_integer(state), do: iterateer(:vector_integer, :integer, :exec_do_star_vector_integer, state)
  def exec_do_star_vector_float(state), do: iterateer(:vector_float, :float, :exec_do_star_vector_float, state)
  def exec_do_star_vector_boolean(state), do: iterateer(:vector_boolean, :boolean, :exec_do_star_vector_boolean, state)
  def exec_do_star_vector_string(state), do: iterateer(:vector_string, :string, :exec_do_star_vector_string, state)

end
