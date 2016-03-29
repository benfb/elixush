defmodule Exush.Interpreter do
  import Exush.Globals.Agent
  import Exush.PushState
  import Exush.Util, only: [recognize_literal: 1]
  import Enum, only: [empty?: 1]

  @doc "Executes a single Push instruction."
  def execute_instruction(instruction, state) do
    update_globals(:point_evaluations_count, get_globals(:point_evaluations_count) + 1)
    if is_nil(instruction) do
      state
    else
      literal_type = recognize_literal(instruction)
      cond do
        literal_type -> push_item(instruction, literal_type, state)
        is_list(instruction) and ([] == instruction) -> push_item([], :vector_integer, push_item([], :vector_float, push_item([], :vector_string, push_item([], :vector_boolean, state))))
        get_globals(:instruction_table) |> Map.has_key?(instruction) -> Map.get(get_globals(:instruction_table), instruction).(state)
        true -> raise(ArgumentError, message: "Undefined instruction: #{Macro.to_string(instruction)}")
      end
    end
  end

  @doc """
  Executes the contents of the exec stack, aborting prematurely if execution limits are
  exceeded. The resulting push state will map :termination to :normal if termination was
  normal, or :abnormal otherwise.
  """
  def eval_push(state), do: eval_push(state, false, false, false)

  def eval_push(state, print_steps), do: eval_push(state, print_steps, false, false)

  def eval_push(state, print_steps, trace), do: eval_push(state, print_steps, trace, false)

  def eval_push(state, print_steps, trace, save_state_sequence) do
    time_limit = if get_globals(:global_evalpush_time_limit) == 0 do
      0
    else
      get_globals(:global_evalpush_time_limit) + System.system_time(:nano_seconds)
    end
    inner_loop(1, state, time_limit)
  end

  def inner_loop(iteration, s, time_limit) do
    both_empty = empty?(s[:exec]) and empty?(s[:environment])
    if ((iteration > get_globals(:global_evalpush_limit)) or both_empty) or (time_limit != 0 and (System.system_time(:nano_seconds) > time_limit)) do
      Map.put(s, :termination, if(both_empty, do: :normal, else: :abnormal))
    else
      if empty?(s[:exec]) do
        inner_loop(iteration + 1, s, time_limit)
      else
        exec_top = top_item(:exec, s)
        s = pop_item(:exec, s)
        s = if is_list(exec_top) do
          Map.put(s, :exec, Enum.concat(exec_top, s[:exec]))
        else
          execute_instruction(exec_top, s)
        end
        inner_loop(iteration + 1, s, time_limit)
      end
    end
  end

  def run_push(code, state), do: run_push(code, state, false, false, false)

  def run_push(code, state, print_steps), do: run_push(code, state, print_steps, false, false)

  def run_push(code, state, print_steps, trace), do: run_push(code, state, print_steps, trace, false)

  def run_push(code, state, print_steps, trace, save_state_sequence) do
    s = if get_globals(:global_top_level_push_code), do: push_item(code, :code, state), else: state
    s = push_item(code, :exec, s)
    s = eval_push(s, print_steps, trace, save_state_sequence)
    IO.puts(List.first(s[:exec]))
    if get_globals(:global_top_level_pop_code), do: pop_item(:code, s), else: s
  end

end
