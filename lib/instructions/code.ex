defmodule Elixush.Instructions.Code do
  @moduledoc "Instructions that operate on the code stack."
  import Elixush.PushState
  import Elixush.Util
  import Elixush.Globals.Agent

  def code_noop(state), do: state

  def noop_open_paren(state), do: state
  def noop_delete_prev_paren_pair(state), do: state

  def code_append(state) do
    if not(Enum.empty?(Enum.drop(state[:code], 1))) do
      new_item = Enum.concat(:code |> stack_ref(0, state) |> ensure_list,
                             :code |> stack_ref(1, state) |> ensure_list)
      if count_points(new_item) <= get_globals(:global_max_points) do
        push_item(new_item, :code, pop_item(:code, pop_item(:code, state)))
      else
        state
      end
    else
      state
    end
  end

  def code_atom(state) do
    if not(Enum.empty?(state[:code])) do
      :code
      |> stack_ref(0, state)
      |> is_list()
      |> Kernel.not
      |> push_item(:boolean, pop_item(:code, state))
    else
      state
    end
  end

  def code_car(state) do
    if not(Enum.empty?(state[:code])) and length(ensure_list(stack_ref(:code, 0, state))) > 0 do
      :code
      |> stack_ref(0, state)
      |> ensure_list
      |> List.first
      |> push_item(:code, pop_item(:code, state))
    else
      state
    end
  end

  def code_cdr(state) do
    if not(Enum.empty?(state[:code])) do
      :code
      |> stack_ref(0, state)
      |> ensure_list
      |> Enum.drop(1)
      |> push_item(:code, pop_item(:code, state))
    else
      state
    end
  end

  def code_cons(state) do
    if not(Enum.empty?(Enum.drop(state[:code], 1))) do
      new_item = List.insert_at(ensure_list(stack_ref(:code, 0, state)), 0, stack_ref(:code, 1, state))
      if count_points(new_item) <= get_globals(:global_max_points) do
        push_item(new_item, :code, pop_item(:code, pop_item(:code, state)))
      else
        state
      end
    else
      state
    end
  end

  def code_do(state) do
    if not(Enum.empty?(state[:code])) do
      :code
      |> stack_ref(0, state)
      |> push_item(:exec, push_item(:code_pop, :exec, state))
    else
      state
    end
  end

  def code_do_star(state) do
    if not(Enum.empty?(state[:code])) do
      push_item(stack_ref(:code, 0, state), :exec, pop_item(:code, state))
    else
      state
    end
  end

  def code_do_star_range(state) do
    if not(Enum.empty?(state[:code]) or Enum.empty?(Enum.drop(state[:integer], 1))) do
      to_do = List.first(state[:code])
      current_index = state[:integer] |> Enum.drop(1) |> List.first
      destination_index = state[:integer] |> List.first
      args_popped = :integer
                    |> pop_item(pop_item(:integer, pop_item(:code, state)))
      increment = cond do
        current_index < destination_index -> 1
        current_index > destination_index -> -1
        true -> 0
      end
      continuation = if increment == 0 do
        args_popped
      else
        [current_index + increment, destination_index, :code_quote, to_do, :code_do_star_range]
        |> push_item(:exec, args_popped)
      end
      push_item(to_do, :exec, push_item(current_index, :integer, continuation))
    else
      state
    end
  end

  def exec_do_star_range(state) do # Differs from code_do_star_range only in the source of the code and the recursive call.
    if not(Enum.empty?(state[:exec]) or Enum.empty?(Enum.drop(state[:integer], 1))) do
      to_do = List.first(state[:exec])
      current_index = state[:integer] |> Enum.drop(1) |> List.first
      destination_index = state[:integer] |> List.first
      args_popped = pop_item(:integer, pop_item(:integer, pop_item(:exec, state)))
      increment = cond do
        current_index < destination_index -> 1
        current_index > destination_index -> -1
        true -> 0
      end
      continuation = if increment == 0 do
        args_popped
      else
        push_item([current_index + increment, destination_index, :exec_do_star_range, to_do], :exec, args_popped)
      end
      push_item(to_do, :exec, push_item(current_index, :integer, continuation))
    else
      state
    end
  end

  def code_do_star_count(state) do
    if not((Enum.empty?(state[:integer]) or List.first(state[:integer]) < 1) or Enum.empty?(state[:code])) do
      [0, List.first(state[:integer]) - 1, :code_quote, List.first(state[:code]), :code_do_star_range] |>
        push_item(:exec, pop_item(:integer, pop_item(:code, state)))
    else
      state
    end
  end

  def exec_do_star_count(state) do # differs from code_do_star_count only in the source of the code and the recursive call
    if not((Enum.empty?(state[:integer]) or List.first(state[:integer]) < 1) or Enum.empty?(state[:exec])) do
      [0, List.first(state[:integer]) - 1, :exec_do_star_range, List.first(state[:exec])]
      |> push_item(:exec, pop_item(:integer, pop_item(:exec, state)))
    else
      state
    end
  end

  def code_do_star_times(state) do
    if state[:integer] != [] and List.first(state[:integer]) >= 1 and state[:code] != [] do
      [0, List.first(state[:integer]) - 1, :code_quote, List.insert_at(ensure_list(List.first(state[:code])), 0, :integer_pop), :code_do_star_range]
      |> push_item(:exec, pop_item(:integer, pop_item(:code, state)))
    else
      state
    end
  end

  # differs from code_do_star_times only in the source of the code and the recursive call
  def exec_do_star_times(state) do
    if not((Enum.empty?(state[:integer]) or List.first(state[:integer]) < 1) or Enum.empty?(state[:exec])) do
      [0, List.first(state[:integer]) - 1, :exec_do_star_range, List.insert_at(ensure_list(List.first(state[:exec])), 0, :integer_pop)]
      |> push_item(:exec, pop_item(:integer, pop_item(:exec, state)))
    else
      state
    end
  end

  def exec_while(state) do
    if Enum.empty?(state[:exec]) do
      state
    else
      if Enum.empty?(state[:boolean]) do
        pop_item(:exec, state)
      else
        if not(stack_ref(:boolean, 0, state)) do
          pop_item(:exec, pop_item(:boolean, state))
        else
          block = stack_ref(:exec, 0, state)
          pop_item(:boolean, push_item(block, :exec, push_item(:exec_while, :exec, state)))
        end
      end
    end
  end

  def exec_do_star_while(state) do
    if Enum.empty?(state[:exec]) do
      state
    else
      block = stack_ref(:exec, 0, state)
      push_item(block, :exec, push_item(:exec_while, :exec, state))
    end
  end

  def code_map(state) do
    if not(Enum.empty?(state[:code]) or Enum.empty?(state[:exec])) do
      first = for item <- ensure_list(List.first(state[:code])) do
        [:code_quote, item, List.first(state[:exec])]
      end
      second = [:code_wrap]
      third = for _item <- state[:code]
                |> List.first
                |> ensure_list
                |> Enum.drop(1), do: :code_cons
      first
      |> Enum.concat(Enum.concat(second, third))
      |> push_item(:exec, pop_item(:code, pop_item(:exec, state)))
    else
      state
    end
  end

  def code_fromboolean(state) do
    if not(Enum.empty?(state[:boolean])) do
      push_item(List.first(state[:boolean]), :code, pop_item(:boolean, state))
    else
      state
    end
  end

  def code_fromfloat(state) do
    if not(Enum.empty?(state[:float])) do
      push_item(List.first(state[:float]), :code, pop_item(:float, state))
    else
      state
    end
  end

  def code_frominteger(state) do
    if not(Enum.empty?(state[:integer])) do
      push_item(List.first(state[:integer]), :code, pop_item(:integer, state))
    else
      state
    end
  end

  def code_quote(state) do
    if not(Enum.empty?(state[:exec])) do
      push_item(List.first(state[:exec]), :code, pop_item(:exec, state))
    else
      state
    end
  end

  def code_if(state) do
    if not(Enum.empty?(state[:boolean]) or Enum.empty?(Enum.drop(state[:code], 1))) do
      instr_to_run = if List.first(state[:boolean]) do
        List.first(Enum.drop(state[:code], 1))
      else
        List.first(state[:code])
      end
      instr_to_run
      |> push_item(:exec, pop_item(:boolean, pop_item(:code, pop_item(:code, state))))
    else
      state
    end
  end

  # differs from code_if in the source of the code and in the order of the if/then parts
  def exec_if(state) do
    if not(Enum.empty?(state[:boolean]) or Enum.empty?(Enum.drop(state[:exec], 1))) do
      instr_to_run = if List.first(state[:boolean]) do
        List.first(state[:exec])
      else
        List.first(Enum.drop(state[:exec], 1))
      end
      instr_to_run
      |> push_item(:exec, pop_item(:boolean, pop_item(:exec, pop_item(:exec, state))))
    else
      state
    end
  end

  def exec_when(state) do
    if not(Enum.empty?(state[:boolean]) or Enum.empty?(state[:exec])) do
      if List.first(state[:boolean]) do
        pop_item(:boolean, state)
      else
        pop_item(:boolean, pop_item(:exec, state))
      end
    else
      state
    end
  end

  def code_length(state) do
    if not(Enum.empty?(state[:code])) do
      state[:code]
      |> List.first
      |> ensure_list
      |> Enum.count
      |> push_item(:integer, pop_item(:code, state))
    else
      state
    end
  end

  def code_list(state) do
    if not(Enum.empty?(state[:code])) do
      new_item = [List.first(Enum.drop(state[:code], 1)), List.first(state[:code])]
      if count_points(new_item) <= get_globals(:global_max_points) do
        push_item(new_item, :code, pop_item(:code, pop_item(:code, state)))
      else
        state
      end
    else
      state
    end
  end

  def code_wrap(state) do
    if not(Enum.empty?(state[:code])) do
      new_item = [List.first(state[:code])]
      if count_points(new_item) <= get_globals(:global_max_points) do
        push_item(new_item, :code, pop_item(:code, state))
      else
        state
      end
    else
      state
    end
  end

  def code_member(state) do
    if not(Enum.empty?(Enum.drop(state[:code], 1))) do
      state[:code]
      |> Enum.drop(1)
      |> List.first
      |> Enum.member?(List.first(state[:code]))
      |> push_item(:boolean, pop_item(:code, pop_item(:code, state)))
    else
      state
    end
  end

  def code_nth(state) do
    top_code_as_list = state[:code] |> List.first |> ensure_list
    top_int = List.first(state[:integer])
    if not((Enum.empty?(state[:integer]) or Enum.empty?(state[:code])) or Enum.empty?(ensure_list(List.first(state[:code])))) do
      top_code_as_list
      |> Enum.at(rem(abs(top_int), Enum.count(top_code_as_list)))
      |> push_item(:code, pop_item(:integer, pop_item(:code, state)))
    else
      state
    end
  end

  def code_nthcdr(state) do
    if not((Enum.empty?(state[:integer]) or Enum.empty?(state[:code])) or Enum.empty?(ensure_list(List.first(state[:code])))) do
      state[:code]
      |> List.first
      |> ensure_list
      |> Enum.drop(state[:integer]
                   |> List.first
                   |> abs
                   |> rem(Enum.count(ensure_list(List.first(state[:code])))))
      |> push_item(:code, pop_item(:integer, pop_item(:code, state)))
    else
      state
    end
  end

  def code_null(state) do
    if not(Enum.empty?(state[:code])) do
      item = List.first(state[:code])
      push_item(is_list(item) and Enum.empty?(item), :boolean, pop_item(:code, state))
    else
      state
    end
  end

  def code_size(state) do
    if not(Enum.empty?(state[:code])) do
      push_item(state[:code] |> List.first |> count_points, :integer, pop_item(:code, state))
    else
      state
    end
  end

  def code_extract(state) do
    if not(Enum.empty?(state[:code]) or Enum.empty?(state[:integer])) do
      push_item(code_at_point(List.first(state[:code]), List.first(state[:integer])), :code, pop_item(:code, pop_item(:integer, state)))
    end
  end

  def code_insert(state) do
    if not(Enum.empty?(Enum.drop(state[:code], 1)) or Enum.empty?(state[:integer])) do
      new_item = insert_code_at_point(List.first(state[:code]), List.first(state[:integer]), Enum.at(state[:code], 1))
      if count_points(new_item) <= get_globals(:global_max_points) do
        new_item
        |> push_item(:code, pop_item(:code, pop_item(:code, pop_item(:integer, state))))
      else
        state
      end
    else
      state
    end
  end

  def code_subst(state) do
    if not(Enum.empty?(Enum.drop(Enum.drop(state[:code], 1), 1))) do
      new_item =
        :code
        |> stack_ref(2, state)
        |> subst(stack_ref(:code, 1, state), stack_ref(:code, 0, state))
      if count_points(new_item) <= get_globals(:global_max_points) do
        push_item(new_item, :code, pop_item(:code, pop_item(:code, pop_item(:code, state))))
      else
        state
      end
    else
      state
    end
  end

  def code_contains(state) do
    if not(Enum.empty?(Enum.drop(state[:code], 1))) do
      push_item(contains_subtree(stack_ref(:code, 1, state), stack_ref(:code, 0, state)), :boolean, pop_item(:code, pop_item(:code, state)))
    else
      state
    end
  end

  def code_container(state) do
    if not(Enum.empty?(Enum.drop(state[:code], 1))) do
      push_item(containing_subtree(stack_ref(:code, 0, state), stack_ref(:code, 1, state)), :code, pop_item(:code, pop_item(:code, state)))
    else
      state
    end
  end

  @doc """
  Returns a lazy sequence containing the positions at which pred
  is true for items in coll.
  """
  def positions(pred, coll) do
    with_nils = for {idx, elt} <- Enum.zip(Stream.iterate(0, &(&1 + 1)), coll) do
      if pred.(elt), do: idx
    end
    Enum.filter(with_nils, &(&1 != nil))
  end

  def code_position(state) do
    if not(Enum.empty?(Enum.drop(state[:code], 1))) do
      &(&1 == stack_ref(:code, 1, state))
      |> positions(ensure_list(stack_ref(:code, 0, state)))
      |> List.first
      |> (fn(x) -> x or -1 end).()
      |> push_item(:integer, pop_item(:code, pop_item(:code, state)))
    end
  end

  def exec_k(state) do
    if not(Enum.empty?(Enum.drop(state[:exec], 1))) do
      push_item(List.first(state[:exec]), :exec, pop_item(:exec, pop_item(:exec, state)))
    else
      state
    end
  end

  def exec_s(state) do
    if not(Enum.empty?(Enum.drop(Enum.drop(state[:exec], 1), 1))) do
      stk = state[:exec]
      x = List.first(stk)
      y = List.first(Enum.drop(stk, 1))
      z = List.first(Enum.drop(Enum.drop(stk, 1), 1))
      if count_points([y, z]) <= get_globals(:global_max_points) do
        push_item(x, :exec, push_item(z, :exec, push_item([y, z], :exec, pop_item(:exec, pop_item(:exec, pop_item(:exec, state))))))
      else
        state
      end
    else
      state
    end
  end

  def exec_y(state) do
    if not(Enum.empty?(state[:exec])) do
      new_item = [:exec_y, List.first(state[:exec])]
      if count_points(new_item) <= get_globals(:global_max_points) do
        push_item(List.first(state[:exec]), :exec, push_item(new_item, :exec, pop_item(:exec, state)))
      else
        state
      end
    else
      state
    end
  end

  @doc "Creates new environment using the top item on the exec stack"
  def environment_new(state) do
    if not(Enum.empty?(state[:exec])) do
      new_exec = top_item(:exec, state)
      parent_env = pop_item(:exec, state)
      push_item(new_exec, :exec, parent_env |> push_item(:environment, state) |> Map.put(:return, []) |> Map.put(:exec, []))
    else
      state
    end
  end

  @doc "Creates new environment using the entire exec stack"
  def environment_begin(state) do
    Map.put(push_item(Map.put(state, :exec, []), :environment, state), :return, [])
  end

  @doc "Ends current environment"
  def environment_end(state) do
    if not(Enum.empty?(state[:environment])) do
      end_environment(state)
    else
      state
    end
  end
end
