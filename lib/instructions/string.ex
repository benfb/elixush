defmodule Elixush.Instructions.String do
  import Elixush.PushState
  import Elixush.Globals.Agent, only: [get_globals: 1]

  def string_frominteger(state) do
    if not(state[:integer] |> Enum.empty?) do
      item = stack_ref(:integer, 0, state)
      push_item(to_string(item), :string, pop_item(:integer, state))
    else
      state
    end
  end

  def string_fromfloat(state) do
    if not(state[:float] |> Enum.empty?) do
      item = stack_ref(:float, 0, state)
      push_item(to_string(item), :string, pop_item(:float, state))
    else
      state
    end
  end

  def string_fromboolean(state) do
    if not(state[:boolean] |> Enum.empty?) do
      item = stack_ref(:boolean, 0, state)
      push_item(to_string(item), :string, pop_item(:boolean, state))
    else
      state
    end
  end

  def string_fromchar(state) do
    if not(state[:char] |> Enum.empty?) do
      item = stack_ref(:char, 0, state)
      push_item(to_string(item), :string, pop_item(:char, state))
    else
      state
    end
  end

  def string_concat(state) do
    if not(state[:string] |> Enum.drop(1) |> Enum.empty?) do
      if(get_globals(:max_string_length) >= Enum.count(stack_ref(:string, 1, state)) + Enum.count(stack_ref(:string, 0, state))) do
        push_item(stack_ref(:string, 1, state) <> stack_ref(:string, 0, state), :string, pop_item(:string, pop_item(:string, state)))
      else
        state
      end
    else
      state
    end
  end

  # TODO: add string_conjchar

  def string_take(state) do
    if not(state[:string] |> Enum.empty?) and not(state[:integer] |> Enum.empty?) do
      push_item(String.slice(stack_ref(:string, 0, state), 0, stack_ref(:integer, 0, state)),
                :string, pop_item(:string, pop_item(:integer, state)))
    else
      state
    end
  end

  def string_substring(state) do # REVIEW: make sure this goes to the same index as clojush
    if not(state[:string] |> Enum.empty?) and not(state[:integer] |> Enum.drop(1) |> Enum.empty?) do
      st = stack_ref(:string, 0, state)
      first_index = min(Enum.count(st), max(0, stack_ref(:integer, 1, state)))
      second_index = min(Enum.count(st), max(first_index, stack_ref(:integer, 0, state)))
      push_item(String.slice(st, first_index, second_index),
                :string, pop_item(:string, pop_item(:integer, pop_item(:integer, state))))
    else
      state
    end
  end

end
