defmodule Elixush.Instructions.Code do
  import Elixush.PushState
  import Elixush.Util
  import Elixush.Globals.Agent

  def code_noop(state), do: state

  # TODO: Look at these to make sure they're in the right place
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
      push_item(not(is_list(stack_ref(:code, 0, state))), :boolean, pop_item(:code, state))
    else
      state
    end
  end

  def code_car(state) do
    if not(Enum.empty?(state[:code])) and length(ensure_list(stack_ref(:code, 0, state))) > 0 do
      stack_ref(:code, 0, state) |> ensure_list
                                 |> List.first
                                 |> push_item(:code, pop_item(:code, state))
    else
      state
    end
  end

  def code_cdr(state) do
    if not(Enum.empty?(state[:code])) do
      stack_ref(:code, 0, state) |> ensure_list
                                 |> Enum.drop(1)
                                 |> push_item(:code, pop_item(:code, state))
    else
      state
    end
  end

  def code_cons(state) do
    if not(Enum.empty?(Enum.drop(state[:code], 1))) do
      new_item = Enum.insert_at(ensure_list(stack_ref(:code, 0, state)), 0, stack_ref(:code, 1, state))
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
      push_item(stack_ref(:code, 0, state), :exec, push_item(:code_pop, :exec, state))
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
      args_popped = pop_item(:integer, pop_item(:integer, pop_item(:code, state)))
      increment = cond do
        current_index < destination_index -> 1
        current_index > destination_index -> -1
        true -> 0
      end
      continuation = if increment == 0 do
        args_popped
      else
        push_item([current_index + increment, destination_index, :code_quote, to_do, :code_do_star_range], :exec, args_popped)
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
    if not((Enum.empty?(state[:integer]) or List.first(state[:integer] < 1)) or Enum.empty?(state[:code])) do
      [0, List.first(state[:integer]) - 1, :code_quote, List.first(state[:code]), :code_do_star_range] |>
        push_item(:exec, pop_item(:integer, pop_item(:code, state)))
    else
      state
    end
  end

  def exec_do_star_count(state) do # differs from code_do_star_count only in the source of the code and the recursive call
    if not((Enum.empty?(state[:integer]) or List.first(state[:integer] < 1)) or Enum.empty?(state[:exec])) do
      [0, List.first(state[:integer]) - 1, :exec_do_star_range, List.first(state[:exec])] |>
        push_item(:exec, pop_item(:integer, pop_item(:exec, state)))
    else
      state
    end
  end

  def code_do_star_times(state) do
    if not((Enum.empty?(state[:integer]) or List.first(state[:integer] < 1)) or Enum.empty?(state[:code])) do
      [0, List.first(state[:integer]) - 1, :code_quote, List.insert_at(ensure_list(List.first(state[:code])), 0, :integer_pop), :code_do_star_range] |>
        push_item(:exec, pop_item(:integer, pop_item(:code, state)))
    else
      state
    end
  end

  def exec_do_star_times(state) do # differs from code_do_star_times only in the source of the code and the recursive call
    if not((Enum.empty?(state[:integer]) or List.first(state[:integer] < 1)) or Enum.empty?(state[:exec])) do
      [0, List.first(state[:integer]) - 1, :exec_do_star_range, List.insert_at(ensure_list(List.first(state[:exec])), 0, :integer_pop)] |>
        push_item(:exec, pop_item(:integer, pop_item(:exec, state)))
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
      third = for _item <- Enum.drop(ensure_list(List.first(state[:code])), 1), do: :code_cons
      Enum.concat(first, Enum.concat(second, third)) |>
        push_item(:exec, pop_item(:code, pop_item(:exec, state)))
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
      if List.first(:boolean, state) do
        List.first(Enum.drop(state[:code], 1))
      else
        List.first(state[:code])
      end |> push_item(:exec, pop_item(:boolean, pop_item(:code, pop_item(:code, state))))
    else
      state
    end
  end

  def exec_if(state) do # differs from code_if in the source of the code and in the order of the if/then parts
    if not(Enum.empty?(state[:boolean]) or Enum.empty?(Enum.drop(state[:exec], 1))) do
      if List.first(:boolean, state) do
        List.first(state[:exec])
      else
        List.first(Enum.drop(state[:exec], 1))
      end |> push_item(:exec, pop_item(:boolean, pop_item(:exec, pop_item(:exec, state))))
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
      push_item(Enum.count(ensure_list(List.first(state[:code]))), :integer, pop_item(:code, state))
    else
      state
    end
  end

  # TODO: continue adding from here https://github.com/lspector/Clojush/blob/master/src/clojush/instructions/code.clj#L313

  @doc "Creates new environment using the top item on the exec stack"
  def environment_new(state) do
    if not(Enum.empty?(state[:exec])) do
      new_exec = top_item(:exec, state)
      parent_env = pop_item(:exec, state)
      push_item(new_exec, :exec, push_item(parent_env, :environment, state) |> Map.put(:return, []) |> Map.put(:exec, []))
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
