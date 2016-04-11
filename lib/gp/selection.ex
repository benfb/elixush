defmodule Elixush.GP.Selection do
  import Enum, only: [count: 1, map: 2, reduce: 2]
  import Elixush.Globals.Agent

  #############################################################################################
  ## tournament selection

  @doc """
  Returns an individual that does the best out of a tournament.
  """
  def tournament_selection(pop, location, argmap \\ %{}) do
    # TODO: Make sure that the argument destructuring of argmap is equivalent
    tournament_size = argmap[:tournament_size]
    trivial_geography_radius = argmap[:trivial_geography_radius]
    total_error_method = argmap[:total_error_method]
    tournament_set = ""
    Enum.each(0..tournament_size, fn(_) ->
      n = if trivial_geography_radius == 0 do
        :rand.uniform(Enum.count(pop)) - 1
      else
        rem(location + (:rand.uniform(trivial_geography_radius * 2) - trivial_geography_radius), Enum.count(pop))
      end
      Enum.at(pop, n)
    end)
    err_fn = case total_error_method do
      :sum -> :total_error
      :hah -> :weighted_error
      :rmse -> :weighted_error
      :ifs -> :weighted_error
      _ -> raise "Unrecognized argument for total_error_method: #{total_error_method}"
    end
    Enum.reduce(tournament_set, fn(i1, i2) ->
      if err_fn.(i1) < err_fn.(i2), do: i1, else: i2
    end)
  end

  #############################################################################################
  ## lexicase selection

  @doc "Retains one random individual to represent each error vector."
  def retain_one_individual_per_error_vector(pop) do
    pop |> Enum.group_by(&(Map.get(&1, :errors))) |> Enum.map(&Enum.random/1)
  end

  def inner_lexicase_loop(survivors, cases) do
    if Enum.empty?(cases) or Enum.empty?(Enum.drop(survivors, 1)) do
      Enum.random(survivors)
    else
      min_err_for_case = survivors |> Enum.map(&(Map.get(&1, :errors)))
                                   |> Enum.map(&(Enum.at(&1, List.first(cases))))
                                   |> Enum.min
      inner_lexicase_loop(Enum.filter(survivors, &(Enum.at(Map.get(&1, :errors), List.first(cases)) == min_err_for_case)), Enum.drop(cases, 1))
    end
  end

  @doc """
  Returns an individual that does the best on the fitness cases when considered one at a
  time in random order.  If trivial-geography-radius is non-zero, selection is limited to parents within +/- r of location
  """
  def lexicase_selection(pop, location, argmap \\ %{}) do
    trivial_geography_radius = argmap[:trivial_geography_radius]
    lower = rem(location - trivial_geography_radius, Enum.count(pop))
    upper = rem(location + trivial_geography_radius, Enum.count(pop))
    subpop = if trivial_geography_radius == 0 do
      pop
    else
      if lower < upper do
        Enum.slice(pop, lower, upper + 1)
      else
        Enum.concat(Enum.slice(pop, lower, Enum.count(pop)), Enum.slice(pop, 0, upper + 1))
      end
    end
    survivors = retain_one_individual_per_error_vector(subpop)
    cases = Enum.shuffle(0..(List.first(subpop) |> Map.get(:errors) |> Enum.count))
    inner_lexicase_loop(survivors, cases)
  end

  #############################################################################################
  ## elitegroup lexicase selection

  @doc """
  Builds a sequence that partitions the cases into sub-sequences, with cases
  grouped when they produce the same set of elite individuals in the population.
  In addition, if group A produces population subset PS(A), and group B
  produces population subset PS(B), and PS(A) is a proper subset of PS(B), then
  group B is discarded.
  """
  def build_elitegroups(pop_agents) do
    IO.puts("Building case elitegroups...")
    pop = retain_one_individual_per_error_vector(pop_agents)
    cases = 0..(pop |> List.first |> Map.get(:errors) |> Enum.count)
    elites = Enum.map(cases, fn(c) ->
      min_error_for_case = pop |> Enum.map(&(Map.get(&1, :errors)))
                               |> Enum.map(&(Enum.at(&1, c)))
                               |> Enum.min
      end)
    all_elitegroups = Map.values(Enum.group_by(&(Enum.at(elites, &1))))
    pruned_elitegroups = Enum.filter(all_elitegroups, fn(eg) ->
      e = MapSet.new(Enum.at(elites, List.first(eg)))
      Enum.any?(all_elitegroups, fn(eg2) ->
        e2 = MapSet.new(Enum.at(elites, List.first(eg2)))
        (e != e2) and MapSet.subset?(e2, e)
      end)
    end)
    # TODO: emulate global elitegroups atom here
    elitegroups = pruned_elitegroups
    IO.puts("#{Enum.count(elitegroups)} elitegroups: #{to_string(elitegroups)}")
  end

  #############################################################################################
  ## implicit fitness sharing

  @doc """
  Takes an individual and calculates and assigns its IFS based on the summed
  error across each test case.
  """
  # TODO: You can't map a function across two items!!!
  def assign_ifs_error_to_individual(ind, summed_reward_on_test_cases) do
    ifs_reward = ind |> Map.get(:errors)
                     |> Enum.map(&(1.0 - &1))
                     |> Enum.zip(summed_reward_on_test_cases)
                     |> Enum.map(&(if &2 == 0, do: 1.0, else: &1 / &2))
                     |> Enum.reduce(&+/2)
    ifs_er = cond do
      :math.pow(10, 20) < ifs_reward -> 0.0
      ifs_reward == 0 -> :math.pow(10, 20)
      :math.pow(10, 20) < (1.0 / ifs_reward) -> :math.pow(10, 20)
      true -> 1.0 / ifs_reward
    end
    Map.put(ind, :weighted_error, ifs_er)
  end

  @doc """
  Calculates the summed fitness for each test case, and then uses it to
  assign an implicit fitness sharing error to each individual. Assumes errors
  are in range [0,1] with 0 being a solution.
  """
  def calculate_implicit_fitness_sharing(pop_agents) do
    # TODO: Figure out what the hell this does
    IO.puts("\nCalculating implicit fitness sharing errors...")
    to_map_across = Enum.reduce(Enum.map(&(Map.get(&1, :errors)), pop), &(Enum.concat(&1, &2)))
    summed_reward_on_test_cases = Enum.map(to_map_across, fn(list_of_errors) ->
      &(1.0 - &1) |> Enum.map(list_of_errors) |> Enum.reduce(&+/2)
    end)
    IO.puts("Implicit fitness sharing reward per test case (lower means population performs worse):")
    IO.puts(to_string(summed_reward_on_test_cases))
    if pop |> Enum.map(:errors) |> Enum.flatten |> Enum.any?(fn(error) -> (error < -0.0000001) || (error > 1.0000001) end) do
      raise "All errors must be in range [0,1]. Please normalize them."
    end
    Enum.map(pop_agents, &(Map.put(&1, assign_ifs_error_to_individual(Map.get(&1, summed_reward_on_test_cases)))))
  end

  #############################################################################################
  ## uniform selection (i.e. no selection, for use as a baseline)

  @doc "Returns an individual uniformly at random."
  def uniform_selection(pop) do
    Enum.random(pop)
  end

  #############################################################################################
  ## parent selection

  @doc "Returns a selected parent."
  def select(pop, location, argmap \\ %{}) do
    parent_selection = argmap[:parent_selection]
    print_selection_counts = argmap[:parent_selection_counts]
    pop_with_meta_errors = Enum.map(pop, fn(ind) -> update_in(ind, [:errors], &(Enum.concat(ind[:meta_errors], &1))) end)
    selected = case parent_selection do
      :tournament -> tournament_selection(pop_with_meta_errors, location, argmap)
      :lexicase -> lexicase_selection(pop_with_meta_errors, location, argmap)
      :elitegroup_lexicase -> elitegroup_lexicase_selection(pop_with_meta_errors)
      :leaky_lexicase -> if :rand.uniform < argmap[:lexicase_leakage] do
        uniform_selection(pop_with_meta_errors)
      else
        lexicase_selection(pop_with_meta_errors, location, argmap)
      end
      :uniform -> uniform_selection(pop_with_meta_errors)
      _ -> raise "Unrecognized argument for parent-selection: #{parent_selection}"
    end
    # TODO: add print_selection_counts
    selected
  end
end
