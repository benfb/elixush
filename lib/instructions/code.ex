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
end
