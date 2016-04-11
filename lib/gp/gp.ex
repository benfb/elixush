defmodule Elixush.GP.GP do
  import Elixush.Globals.Agent
  import Elixush.GP.Report
  registered_instructions = get_globals(:registered_instructions)
  push_argmap = %{
    # ----------------------------------------
    #   Clojush system arguments
    # ----------------------------------------
    use_single_thread: true, # When true, Clojush will only use a single thread
    random_seed: "REPLACEWITHSEED", # The seed for the random number generator
    save_initial_population: false, # When true, saves the initial population
    #
    # ----------------------------------------
    #   Standard GP arguments
    # ----------------------------------------
    error_function: fn(_p) -> [0] end, # Function that takes a program and returns a list of errors
    error_threshold: 0, # Pushgp will stop and return the best program if its total error is <= the error-threshold
    atom_generators: Enum.concat(registered_instructions, # The instructions that pushgp will use in random code
                                 [fn() -> :rand.unform(100) - 1 end,
                                  fn() -> :rand.uniform() end]),
    population_size: 1000, # Number of individuals in the population
    max_generations: 1001, # The maximum number of generations to run GP
    max_point_evaluations: 10 * :math.pow(10, 100), # The limit for the number of point (instruction) evaluations to execute during the run
    max_points: 100, # Maximum size of push programs and push code, as counted by points in the program. 1/2 this limit is used as the limit for sizes of Plush genomes.
    max_genome_size_in_initial_program: 50, #  Maximum size of initial Plush genomes in generation 0. Keep in mind that genome lengths will otherwise be limited by 1/2 of :max-points
    evalpush_limit: 150, # The number of Push instructions that can be evaluated before stopping evaluation
    evalpush_time_limit: 0, # The time in nanoseconds that a program can evaluate before stopping, 0 means no time limit
    reuse_errors: true, # When true, children produced through direct reproduction will not be re-evaluated but will have the error vector of their parent
    pass_individual_to_error_function: false, # When true, entire individuals (rather than just programs) are passed to error functions
    #
    # ----------------------------------------
    #   Genetic operator probabilities
    # ----------------------------------------
    # The map supplied to :genetic-operator-probabilities should contain genetic operators
    # that sum to 1.0. All available genetic operators are defined in clojush.pushgp.breed.
    # Along with single operators, pipelines (vectors) containing multiple operators are
    # also allowed, where each operator is applied to the child of the previous operator, along
    # with newly selecting individuals where necessary. If an operator is preceeded by
    # :make-next-operator-revertable, it will only keep the child if it is at least as good as
    # its (first) parent on every test case.
    genetic_operator_probabilities: %{
      reproduction: 0.0,
      alternation: 0.7,
      unform_mutation: 0.1, # Somewhat equivalent to normal Push's ULTRA
      alternation: 0.2,
      uniform_mutation: 0.2,
      uniform_close_mutation: 0.0,
      uniform_silence_mutation: 0.0,
      make_next_operator_revertable: 0.0, # Equivalent to a hill-climbing version of uniform-silence-mutation
      autoconstruction: 0.0,
      uniform_deletion: 0.0
    },
    #
    # ----------------------------------------
    #   Arguments related to genetic operators
    # ----------------------------------------
    alternation_rate: 0.01, # When using alternation, how often alternates between the parents
    alignment_deviation: 10, # When using alternation, the standard deviation of how far alternation may jump between indices when switching between parents
    uniform_mutation_rate: 0.01, # The probability of each token being mutated during uniform mutation
    uniform_mutation_constant_tweak_rate: 0.5, # The probability of using a constant mutation instead of simply replacing the token with a random instruction during uniform mutation
    uniform_mutation_float_gaussian_standard_deviation: 1.0, # The standard deviation used when tweaking float constants with Gaussian noise
    uniform_mutation_int_gaussian_standard_deviation: 1, # The standard deviation used when tweaking integer constants with Gaussian noise
    uniform_mutation_string_char_change_rate: 0.1, # The probability of each character being changed when doing string constant tweaking
    uniform_mutation_tag_gaussian_standard_deviation: 100, # The standard deviation used when tweaking tag locations with Gaussian noise
    uniform_close_mutation_rate: 0.1, # The probability of each :close being incremented or decremented during uniform close mutation
    close_increment_rate: 0.2, # The probability of making an increment change to :close during uniform close mutation, as opposed to a decrement change
    uniform_deletion_rate: 0.01, # The probability that any instruction will be deleted during uniform deletion
    uniform_silence_mutation_rate: 0.1, # The probability of each :silent being switched during uniform silent mutation
    replace_child_that_exceeds_size_limit_with: :random, # When a child is produced that exceeds the size limit of (max_points / 2), this is used to determine what program to return. Options include :parent, :empty, :random, :truncate
    parent_reversion_probability: 1.0, # The probability of a child being reverted to its parent by a genetic operator that has been made revertable, if the child is not as good as the parent on at least one test case
    autoconstructive: false, # if true then :genetic_operator_probabilities will be {:autoconstruction 1.0}, :epigenetic_markers will be [:close :silent], and :atom_generators will include everything in (registered_for_stacks [:integer :boolean :exec :genome]). You will probably also want to provide a high value for :max_generations.
    autoconstructive_integer_rand_enrichment: 1, # the number of extra instances of autoconstructive_integer_rand to include in :atom_generators for autoconstruction. If negative then autoconstructive_integer_rand will not be in :atom_generators at all
    autoconstructive_boolean_rand_enrichment: -1, # the number of extra instances of autoconstructive_boolean_rand to include in :atom-generators for autoconstruction. If negative then autoconstructive_boolean_rand will not be in :atom-generators at all
    #
    # ----------------------------------------
    #   Epignenetics
    # ----------------------------------------
    epigenetic_markers: [:close], # A vector of the epigenetic markers that should be used in the individuals. Implemented options include: :close, :silent
    close_parens_probabilities: [0.772, 0.206, 0.021, 0.001], # A vector of the probabilities for the number of parens ending at that position. See random-closes in clojush.random
    silent_instruction_probability: 0.2, # If :silent is used as an epigenetic-marker, this is the probability of random instructions having :silent be true
    #
    # ----------------------------------------
    #   Arguments related to parent selection
    # ----------------------------------------
    parent_selection: :lexicase, # The parent selection method. Options include :tournament, :lexicase, :elitegroup_lexicase, :uniform :leaky_lexicase
    lexicase_leakage: 0.1, # If using leaky lexicase selection, the percentage of selection events that will return random (tourny 1) individuals
    tournament_size: 7, # If using tournament selection, the size of the tournaments
    total_error_method: :sum, # The method used to compute total error. Options include :sum (standard), :hah (historically_assessed hardness), :rmse (root mean squared error), and :ifs (implicit fitness sharing)
    normalization: :none, # The method used to normalize the errors to the range [0,1], with 0 being best. Options include :none (no normalization), :divide_by_max_error (divides by value of argument :max_error), :e_over_e_plus_1 (e/(e+1) = 1 _ 1/(e+1))
    max_error: 1000, # If :normalization is set to :max_error, will use this number for normalization
    meta_error_categories: [], # A vector containing meta_error categories that can be used for parent selection, but do not affect total error. See clojush.evaluate for options.
    trivial_geography_radius: 0, # If non_zero, this is used as the radius from which to select individuals for tournament or lexicase selection
    decimation_ratio: 1, # If >= 1, does nothing. Otherwise, is the percent of the population size that is retained before breeding. If 0 < decimation_ratio < 1, decimation tournaments will be used to reduce the population to size (* population_size decimation_ratio) before breeding.
    decimation_tournament_size: 2, # Size of the decimation tournaments
    print_selection_counts: false, # If true, keeps track of and prints the number of times each individual was selected to be a parent
    #
    # ----------------------------------------
    #   Arguments related to the Push interpreter
    # ----------------------------------------
    pop_when_tagging: true, # When true, tagging instructions will pop the exec stack when tagging; otherwise, the exec stack is not popped
    tag_limit: 10000, # The size of the tag space
    top_level_push_code: false, # When true, run_push will push the program's code onto the code stack prior to running
    top_level_pop_code: false, # When true, run_push will pop the code stack after running the program
    #
    # ----------------------------------------
    #   Arguments related to generational and final reports
    # ----------------------------------------
    report_simplifications: 100, # The number of simplification steps that will happen during report simplifications
    final_report_simplifications: 1000, # The number of simplification steps that will happen during final report simplifications
    problem_specific_report: &default_problem_specific_report/5, # A function can be called to provide a problem_specific report, which happens after the normal generational report is printed
    return_simplified_on_failure: false, # When true, will simplify the best indivual and return it, even if the error threshold has not been reached. This will make failures return the same as successes
    print_errors: true, # When true, prints the error vector of the best individual
    print_history: false, # When true, prints the history of the best individual's ancestors' total errors
    print_timings: false, # If true, report prints how long different parts of evolution have taken during the current run.
    print_error_frequencies_by_case: false, # If true, print reports of error frequencies by case each generation
    print_cosmos_data: false, # If true, report prints COSMOS data each generation.
    maintain_ancestors: false, # If true, save all ancestors in each individual (costly)
    print_ancestors_of_solution: false, # If true, final report prints the ancestors of the solution. Requires :maintain_ancestors to be true.
    print_behavioral_diversity: false, # If true, prints the behavioral diversity of the population each generation. Note: The error function for the problem must support behavioral diversity. For an example, see wc.clj
    print_homology_data: false, # If true, prints the homology statistics
    #
    # ----------------------------------------
    #   Arguments related to printing JSON or CSV logs
    # ----------------------------------------
    print_csv_logs: false, # Prints a CSV log of the population each generation
    print_json_logs: false, # Prints a JSON log of the population each generation
    csv_log_filename: "log.csv", # The file to print CSV log to
    json_log_filename: "log.json", # The file to print JSON log to
    csv_columns: [:generation, :location, :total_error, :push_program_size], # The columns to include in a printed CSV beyond the generation and individual. Options include: [:generation :location :parent_uuids :genetic_operators :push_program_size :plush_genome_size :push_program :plush_genome :total_error :test_case_errors]
    log_fitnesses_for_all_cases: false, # If true, the CSV and JSON logs will include the fitnesses of each individual on every test case
    json_log_program_strings: false, # If true, JSON logs will include program strings for each individual
  }

  def load_push_argmap(argmap) do
    Enum.each(argmap, fn{argkey, argval} ->
      if Map.get(push_argmap, argkey) == nil do
        raise "Argument key #{argkey} is not a recognized argument to pushgp."
      end
      Map.put(push_argmap, argkey, argval)
    end)
  end
  # if push_argmap[:autoconstructive] do
  #   Map.put(push_argmap, :genetic_operator_probabilities, %{autoconstruction: 1.0})
  #   Map.put(push_argmap, :epigenetic_markers, [:close, :silent])
  #   Enum.each(registered_for_stacks([:integer, :boolean, :exec, :genome]), fn(instr) ->
  #     if not(Enum.any?(push_argmap[:atom_generators], fn(i) -> i == instr end)) do
  #       Map.put(push_argmap, :atom_generators, Enum.concat(push_argmap[:atom_generators], [instr]))
  #     end
  #   end)
  #   Enum.each(1..push_argmap[:autoconstructive_integer_rand_enrichment], )
  # end

  @doc "Resets all Elixush globals according to values in push_argmap."
  def reset_globals do
    Enum.each(get_globals_keys, fn{k, _} -> "k" end)
    # if String.contains(to_string(k) do
    #   update_globals(k, push_argmap[k])
    # end
  end

  @doc "Loads argmap into push_argmap, then resets all Elixush globals according to values in push_argmap."
  def reset_globals(argmap) do
    load_push_argmap(argmap)
    reset_globals
  end

  # TODO: make sure this is equivalent to clojure argument destrucuring
  # def compute_errors(pop_agents, rand_gens, argmap) do
  #   Enum.map()
  #   fn()
  #   Map.put(&1, evaluate_individual())
  # end
end
