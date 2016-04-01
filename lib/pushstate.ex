defmodule Elixush.PushState do
  import Enum, only: [empty?: 1]
  import Elixush.Globals.Agent

  @doc "Returns an empty push state."
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

  def state_pretty_print(state) do
    Enum.each(get_globals(:push_types), fn(t) ->
      IO.puts "#{t} = #{Macro.to_string(Map.get(state, t))}"
    end)
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
    if empty?(stack), do: :no_stack_item, else: Enum.at(stack, position)
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
  Ends the current environment by popping the :environment stack and replacing
  all stacks with those on the environment stack. Then, everything on the old
  :return stack is pushed onto the :exec stack.
  """
  @spec end_environment(map) :: map
  def end_environment(state) do
    new_env = top_item(:environment, state)
    new_exec = Enum.concat(Map.get(state, :exec), Map.get(new_env, :exec))
    # HACK: anonymous functions used to emulate loop/recur from clojure
    loop = fn
      (_f, old_return, new_state) when hd(old_return) -> new_state
      (f, old_return, new_state) -> f.(f, tl(old_return), push_item(hd(old_return), :exec, new_state))
    end
    loop.(loop, Map.get(state, :return), Map.merge(new_env, %{:exec => new_exec, :auxiliary => Map.get(state, :auxiliary)}))
  end

  @doc "Returns a list of all registered instructions with the given type name as a prefix."
  @spec registered_for_type(atom, map) :: Enum.t
  def registered_for_type(type, argmap \\ %{}) do
    include_randoms = Map.get(argmap, :include_randoms, true)
    for_type = Enum.filter(get_globals(:registered_instructions), &(String.starts_with?(Atom.to_string(&1), Atom.to_string(type))))
    if include_randoms do
      for_type
    else
      Enum.filter(for_type, &(not(String.ends_with?(Atom.to_string(&1), "_rand"))))
    end
  end

  @doc "Returns a list of all registered instructions aside from random instructions."
  @spec registered_nonrandom :: Enum.t
  def registered_nonrandom do
    Enum.filter(get_globals(:registered_instructions), &(not(String.ends_with?(Atom.to_string(&1), "_rand"))))
  end

  @doc """
  Takes a list of stacks and returns all instructions that have all
  of their stack requirements fulfilled. This won't include random instructions
  unless :random is in the types list. This won't include parenthesis-altering
  instructions unless :parentheses is in the types list.
  """
  @spec registered_for_stacks(Enum.t) :: Enum.t
  def registered_for_stacks(types_list) do
    types_list
  end

  @doc """
  Takes a map of stack names and entire stack states, and returns a new push-state
  with those stacks set.
  """
  @spec push_state_from_stacks(map) :: map
  def push_state_from_stacks(stack_assignments) do
    Map.merge(make_push_state, stack_assignments)
  end
end
