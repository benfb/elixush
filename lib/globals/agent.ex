defmodule Elixush.Globals.Agent do
  @moduledoc """
  The values defined here tend to remain constant over all runs. The atoms
  not starting with "global_" are used in a variety of places and therefore
  it is easiest to keep them global. The atoms starting with "global_"
  may change depending on arguments to pushgp.

  Most of the values and atoms in this file are those that are used by Push
  instructions; all others, with few exceptions, should be defined in push_argmap
  in pushgp.ex and should be passed to whatever functions use them as arguments.
  """

  def start_link(name) do
    Agent.start_link(fn -> %{
      push_types: [:exec, :code, :integer, :float, :boolean, :char, :string, :zip,
                   :vector_integer, :vector_float, :vector_boolean, :vector_string,
                   :input, :output, :auxiliary,
                   :tag, :return, :environment, :genome],
      literals: %{
        integer: &is_integer/1,
        float: &is_float/1,
        string: &is_binary/1,
        boolean: &is_boolean/1,
        vector_integer: &(is_list(&1) and is_integer(hd(&1))),
        vector_float: &(is_list(&1) and is_float(hd(&1))),
        vector_string: &(is_list(&1) and is_binary(hd(&1))),
        vector_boolean: &(is_list(&1) and is_boolean(hd(&1)))
      },
      instruction_table: %{},
      # These definitions are used by instructions to keep computed values within limits
      # or when using random instructions.
      max_number_magnitude: 1_000_000_000_000, # Used by keep-number-reasonable as the maximum size of any integer or float
      min_number_magnitude: 1.0E-10, # Used by keep-number-reasonable as the minimum magnitude of any float
      max_string_length: 5000, # Used by string instructions to ensure that strings don't get too large
      max_vector_length: 5000, # Used by vector instructions to ensure that vectors don't get too large
      min_random_integer: -10, # The minumum value created by the integer_rand instruction
      max_random_integer: 10, # The maximum value created by the integer_rand instruction
      min_random_float: -1.0, # The minumum value created by the float_rand instruction
      max_random_float: 1.0, # The maximum value created by the float_rand instruction
      min_random_string_length: 1, # The minimum length of string created by the string_rand instruction
      max_random_string_length: 10, # The maximum length of string created by the string_rand instruction
      max_points_in_random_expressions: 50, # The maximum length of code created by the code_rand instruction
      # These atoms are used in different places and are therefore difficult to make fully functional
      evaluations_count: 0, # Used to count the number of times GP evaluates an individual
      point_evaluations_count: 0, # Used to count the number of instructions that have been executed
      timer_atom: 0, # Used for timing of different parts of PushGP
      timing_map: 0, # Used for timing of different parts of pushgp
      solution_rates: Stream.cycle([0]), # Used in historically-assessed hardness
      elitegroups: [], # Used for elitegroup lexicase selection (will only work if lexicase-selection is off)
      population_behaviors: [], # Used to store the behaviors of the population for use in tracking behavioral diversity
      selection_counts: %{}, # Used to store the number of selections for each individual, indexed by UUIDs
      # These definitions are used by Push instructions and therefore must be global
      global_atom_generators: [], # The instructions and literals that may be used in Push programs.
      global_max_points: 100, # The maximum size of a Push program. Also, the maximum size of code that can appear on the exec or code stacks.
      global_tag_limit: 10_000, # The size of the tag space
      global_epigenetic_markers: [:close], # A vector of the epigenetic markers that should be used in the individuals. Implemented options include: :close, :silent
      global_close_parens_probabilities: [0.772, 0.206, 0.021, 0.001], # A vector of the probabilities for the number of parens ending at that position. See random-closes in clojush.random
      global_silent_instruction_probability: 0.2, # If :silent is used as an epigenetic-marker, this is the probability of random instructions having :silent be true
      # These definitions are used by run-push (and functions it calls), and must be global since run-push is called by the problem-specifc error functions
      global_top_level_push_code: false, # When true, run-push will push the program's code onto the code stack prior to running
      global_top_level_pop_code: false, # When true, run-push will pop the code stack after running the program
      global_evalpush_limit: 150, # The number of Push instructions that can be evaluated before stopping evaluation
      global_evalpush_time_limit: 0, # The time in nanoseconds that a program can evaluate before stopping, 0 means no time limit
      global_pop_when_tagging: true, # When true, tagging instructions will pop the exec stack when tagging; otherwise, the exec stack is not popped
      # These definitions are used by some problem-specific error functions, and must therefore be global
      global_parent_selection: :lexicase, # The type of parent selection used
      global_print_behavioral_diversity: false, # When true, reports will print the behavioral diversity of the population
      registered_instructions: %MapSet{}
    } end, name: name)
  end

  # @doc "Get all keys from the globals service"
  # @spec get_globals_keys() :: any
  # def get_globals_keys() do
  #   Agent.get(__MODULE__, &Map.keys(&1))
  # end

  @doc "Get a key from the globals service"
  @spec get_globals(atom) :: any
  def get_globals(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  @doc "Update a key in the globals service"
  @spec update_globals(atom, any) :: any
  def update_globals(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end
end
