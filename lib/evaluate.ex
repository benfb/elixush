defmodule Elixush.Evaluate do
  @moduledoc "Code to evaluate individual Push programs."
  import Enum, only: [count: 1, map: 2, reduce: 2]
  import Elixush.Globals.Agent

  # ######################################################
  # calculate the solution rates (only called from pushgp)
  @spec calculate_hah_solution_rates(Enum.t, map) :: nil
  def calculate_hah_solution_rates(pop_agents, argmap) do
    total_error_method = Map.get(argmap, :total_error_method)
    error_threshold = Map.get(argmap, :error_threshold)
    population_size = Map.get(argmap, :population_size)

    if total_error_method == :hah do
      error_seqs = Enum.map(pop_agents, &(Map.get(&1, :errors)))
      num_cases = length(hd(error_seqs))
      new_solution_rates = for i <- 0..num_cases do
        (error_seqs
         |> Enum.map(&(Enum.fetch(&1, i)))
         |> Enum.filter(&(&1 <= error_threshold))
         |> length) / population_size
      end
      update_globals(:solution_rates, new_solution_rates)
      IO.write("\nSolution rates: ")
      IO.puts(get_globals(:solution_rates))
    end
  end

  # #####################
  # calculate meta-errors

  @doc """
  Calculates one meta-error for each meta-error category provided. Each
  meta-error-category should either be a keyword for a built-in meta category
  or a function that takes an individual and an argmap and returns a meta
  error value. The built-in meta categories include:
    :size (minimize size of program)
    :compressibility (minimize ammount a program compresses compared to itself)
    :total-error (minimize total error)
    :unsolved-cases (maximize number of cases with zero error)
  """
  @spec calculate_meta_errors(map, map) :: Enum.t
  def calculate_meta_errors(ind, argmap) do
    meta_error_fn = fn(cat) ->
      cond do
        is_function(cat) -> cat.(ind, argmap)
        cat == :size -> length(Map.get(ind, :genome))
        cat == :total_error -> Map.get(ind, :total_error)
        cat == :unsolved_cases ->
          length(Enum.filter(Map.get(ind, :errors), &(&1 > Map.get(argmap, :error_threshold))))
        true ->
          raise(ArgumentError, message: "Unrecognized meta category: #{cat}")
      end
    end
    Enum.map(Map.get(argmap, :meta_error_categories), meta_error_fn)
  end

  # ####################
  # evaluate individuals

  @spec compute_total_error(Enum.t) :: float
  def compute_total_error(errors) do
    Enum.reduce(errors, &+/2)
  end

  @spec compute_root_mean_squared_error(Enum.t) :: Enum.t
  def compute_root_mean_squared_error(errors) do
    mse = errors |> map(&(&1 * &1)) |> reduce(&+/2)
    :math.sqrt(mse / count(errors))
  end

  @spec compute_hah_error(Enum.t) :: float
  def compute_hah_error(errors) do
    :solution_rates
    |> get_globals
    |> Enum.zip(errors)
    |> Enum.map(fn({rate, e}) -> e * (rate - 1.01) end)
    |> Enum.reduce(&+/2)
  end

  @doc "Normalizes errors to [0,1] if normalize isn't :none."
  @spec normalize_errors(Enum.t, atom, integer) :: Enum.t
  def normalize_errors(errors, normalization, max_error) do
    if normalization == :none do
      errors
    else
      map(errors, fn(err) ->
        case normalization do
          :divide_by_max_error ->
            if err >= max_error, do: 1.0, else: err / max_error
          :e_over_e_plus_1 ->
            err / (err + 1)
          true ->
            raise(ArgumentError, message: "Unrecognized argument for normalization: #{normalization}")
        end
      end)
    end
  end

  @doc """
  Returns the given individual with errors, total-errors, and weighted-errors,
  computing them if necessary.
  """
  @spec evaluate_individual(map, fun, any) :: map
  def evaluate_individual(i, error_function, rand_gen) do
    default_args = %{
      reuse_errors: true,
      print_history: false,
      total_error_method: :sum,
      normalization: :none,
      max_error: 1000
    }
    evaluate_individual(i, error_function, rand_gen, default_args)
  end

  # TODO: Add rand_gen argument
  #   See https://github.com/lspector/Clojush/blob/master/src/clojush/evaluate.clj#L92
  @spec evaluate_individual(map, fun, any, map) :: map
  def evaluate_individual(i, error_function, _, argmap) do
    reuse_errors = Map.get(argmap, :reuse_errors)
    print_history = Map.get(argmap, :print_history)
    total_error_method = Map.get(argmap, :total_error_method)
    normalization = Map.get(argmap, :normalization)
    max_error = Map.get(argmap, :max_error)
    pass_individual_to_error_function =
      Map.get(argmap, :pass_individual_to_error_function)
    p = Map.get(i, :program)
    raw_errors =
      if not(reuse_errors) or is_nil(Map.get(i, :errors)) or is_nil(Map.get(i, :total_error)) do
        if pass_individual_to_error_function do
          error_function.(i)
        else
          error_function.(p)
        end
      end
    e = if reuse_errors and not(is_nil(Map.get(i, :errors))) do
      Map.get(i, :errors)
    else
      update_globals(:evaluations_count, get_globals(:evaluations_count) + 1)
      normalize_errors(raw_errors, normalization, max_error)
    end
    te = if reuse_errors and not(is_nil(Map.get(i, :total_error))) do
      Map.get(i, :total_error)
    else
      compute_total_error(raw_errors)
    end
    ne = if reuse_errors and not(is_nil(Map.get(i, :normalized_error))) do
      Map.get(i, :normalized_error)
    else
      compute_total_error(e)
    end
    we = case total_error_method do
      :hah -> compute_hah_error(e)
      :rmse -> compute_root_mean_squared_error(e)
      _else -> nil
    end
    hist =
      if print_history do
        List.insert_at(Map.get(i, :history), 0, te)
      else
        Map.get(i, :history)
      end
    new_ind = Map.merge(i, %{
      errors: e,
      total_error: te,
      weighted_error: we,
      normalized_error: ne,
      history: hist,
    })
    me = calculate_meta_errors(new_ind, argmap)
    Map.put(new_ind, :meta_errors, me)
  end
end
