defmodule Exush.Interpreter do
  import Exush.Globals
  import Enum, only: [empty?: 1]

  @doc "Add the provided name to the global list of registered instructions."
  def register_instruction(name) do
    if MapSet.member?(get_globals(:registered_instructions), name) do
      raise(ArgumentError, message: "Duplicate Push instruction defined: #{name}")
    else
      update_globals(:registered_instructions, MapSet.put(get_globals(:registered_instructions), name))
    end
  end

  def define_registered(instruction, definition) do
      register_instruction(instruction)
      old_instruction_table = get_globals(:instruction_table)
      new_instruction_table = Map.put(old_instruction_table, instruction, definition)
      update_globals(:instruction_table, new_instruction_table)
  end

  @doc "If thing is a literal, return its type -- otherwise return false."
  def recognize_literal(thing) do
    # HACK: anonymous functions used to emulate loop/recur from clojure
    loop = fn(f, m) ->
      if m |> Map.to_list |> List.first |> is_nil do
        nil
      else
        {type, pred} = hd(Map.to_list(m))
        if pred.(thing) do
          type
        else
          f.(f, Map.new(tl(Map.to_list(m))))
        end
      end
    end
    loop.(loop, get_globals(:literals))
  end

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

  def state_pretty_print(state) do
    for t <- get_globals(:push_types), do: IO.puts "#{t} = #{state[t]}"
  end

  @doc """
  Returns a copy of the state with the value pushed on the named stack. This is a utility,
  not for use in Push programs.
  """
  def push_item(value, type, state) do
    Map.put(state, type, List.insert_at(state[type], 0, value))
  end

  @doc """
  Returns the top item of the type stack in state. Returns :no-stack-item if called on
  an empty stack. This is a utility, not for use as an instruction in Push programs.
  """
  def top_item(type, state) do
    stack = state[type]
    if empty?(stack), do: :no_stack_item, else: List.first(stack)
  end

  @doc """
  Returns the indicated item of the type stack in state. Returns :no-stack-item if called
  on an empty stack. This is a utility, not for use as an instruction in Push programs.
  NOT SAFE for invalid positions.
  """
  @spec stack_ref(atom, integer, map) :: any
  def stack_ref(type, position, state) do
    stack = Map.get(state, type)
    if empty?(stack) do
      :no_stack_item
    else
      Enum.at(stack, position)
    end
  end

  @doc """
  Puts value at position on type stack in state. This is a utility, not for use
  as an instruction in Push programs. NOT SAFE for invalid positions.
  """
  def stack_assoc(value, type, position, state) do
    stack = Map.get(state, type)
    new_stack = List.insert_at(stack, position, value)
    Map.put(state, type, new_stack)
  end

  @doc """
  Returns a copy of the state with the specified stack popped. This is a utility,
  not for use as an instruction in Push programs.
  """
  @spec pop_item(atom, map) :: map
  def pop_item(type, state) do
    Map.put(state, type, state |> Map.get(type) |> tl)
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

  def make_push_state do
    %{exec: [],
      code: [],
      integer: [],
      float: [],
      boolean: [],
      char: [],
      string: [],
      zip: [],
      vector_integer: [],
      vector_float: [],
      vector_boolean: [],
      vector_string: [],
      input: [],
      output: [],
      auxiliary: [],
      tag: [],
      return: [],
      environment: [],
      genome: []
    }
  end

end
