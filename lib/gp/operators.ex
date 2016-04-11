defmodule Elixush.GP.Operators do
  import Elixush.Globals.Agent

  #############################################################################################
  ## reproduction

  @doc "Returns parent"
  def reproduction(ind, _argmap \\ %{}) do
    ind
  end

  #############################################################################################
  ## uniform mutation

  @doc "Returns gaussian noise of mean 0, std dev 1."
  def gaussian_noise_factor do
    :math.sqrt(:math.log(:rand.uniform) * -2.0) * :math.cos(:math.pi * :rand.uniform * 2.0)
  end

  @doc "Returns n perturbed with std dev sd."
  def perturb_with_gaussian_noise(sd, n) do
    n + (sd * gaussian_noise_factor)
  end

  @doc "Tweaks the tag with Gaussian noise."
  def tag_gaussian_tweak(instr_map, uniform_mutation_tag_gaussian_standard_deviation) do
    instr = instr_map[:instruction]


    tagparts = String.split(to_string(instr), "_")
    {tag_num, _} = List.last(tagparts) |> Code.eval_string # TODO: make sure this works
    new_tag_num = uniform_mutation_tag_gaussian_standard_deviation |>
                  perturb_with_gaussian_noise(tag_num) |>
                  round |>
                  rem(get_globals(:global_tag_limit))
    new_instr = tagparts |> Enum.drop(-1)
                         |> Enum.concat([to_string(new_tag_num)])
                         |> Enum.join("_")
                         |> String.to_atom
    Map.put(instr_map, :instruction, new_instr)
  end

  @doc """
  Uniformly mutates individual. For each token in program, there is
  uniform-mutation-rate probability of being mutated. If a token is to be
  mutated, it has a uniform-mutation-constant-tweak-rate probability of being
  mutated using a constant mutator (which varies depending on the type of the
  token), and otherwise is replaced with a random instruction.
  """
  def uniform_mutation(ind, argmap \\ %{}) do
    # TODO: Does destructuring work like this?
    uniform_mutation_rate = argmap[:uniform_mutation_rate]
    uniform_mutation_constant_tweak_rate = argmap[:uniform_mutation_constant_tweak_rate]
    uniform_mutation_float_gaussian_standard_deviation = argmap[:uniform_mutation_float_gaussian_standard_deviation]
    uniform_mutation_int_gaussian_standard_deviation = argmap[:uniform_mutation_int_gaussian_standard_deviation]
    uniform_mutation_tag_gaussian_standard_deviation = argmap[:uniform_mutation_tag_gaussian_standard_deviation]
    uniform_mutation_string_char_change_rate = argmap[:uniform_mutation_string_char_change_rate]
    maintain_ancestors = argmap[:maintain_ancestors]
    atom_generators = argmap[:atom_generators]

    string_tweak = fn(st) -> # TODO: apply str here
      Enum.map(st, fn(c) ->
        if :rand.uniform < uniform_mutation_string_char_change_rate do
          String.codepoints("\n\t !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~") |> Enum.random
        else
          c
        end
      end)
    end

    instruction_mutator = fn(token) ->  # TODO: Add random_plush_genome function
      Map.put(token, :instruction, random_plush_genome(1, atom_generators, argmap) |> List.first |> Map.get(:instruction))
    end

    constant_mutator = fn(token) ->
      const = token[:instruction]
      # TODO: add tag_instruction?
      if tag_instruction?(const) do
        tag_gaussian_tweak(token, uniform_mutation_tag_gaussian_standard_deviation)
      else
        Map.put(token, :instruction, cond do
          is_float(const) -> perturb_with_gaussian_noise(uniform_mutation_float_gaussian_standard_deviation, const)
          is_integer(const) -> perturb_with_gaussian_noise(uniform_mutation_int_gaussian_standard_deviation, const) |> round
          is_binary(const) -> string_tweak.(const)
          const == true or const == false -> Enum.random([true, false])
          true -> random_plush_genome(1, atom_generators, argmap) |> List.first |> Map.get(:instruction)
        end)
      end
    end

    token_mutator = fn(token) ->
      if :rand.uniform < uniform_mutation_rate do
        if :rand.uniform < uniform_mutation_constant_tweak_rate do
          constant_mutator.(token)
        else
          instruction_mutator.(token)
        end
      else
        token
      end
    end

    new_genome = Enum.map(ind[:genome], token_mutator)
    make_individual(genome: new_genome,
                    history: ind[:history],
                    ancestors: if maintain_ancestors do
                      List.insert_at(ind[:ancestors], 0, ind[:genome])
                    else
                      ind[:ancestors]
                    end)
  end

  #############################################################################################
  ## uniform close mutation

  @doc """
  Uniformly mutates the :close's in the individual's instruction maps. Each
  :close will have a uniform-close-mutation-rate probability of being changed,
  and those that are changed have a close-increment-rate chance of being
  incremented, and are otherwise decremented.
  """
  def uniform_close_mutation(ind, args \\ []) do
    uniform_close_mutation_rate = args[:uniform_close_mutation_rate]
    close_increment_rate = args[:close_increment_rate]
    epigenetic_markers = args[:epigenetic_markers]
    maintain_ancestors = args[:maintain_ancestors]
    if Enum.any?(epigenetic_markers, &(&1 == :close)) do
      close_mutator = fn(instr_map) ->
        closes = Map.get(instr_map, :close, 0)
        Map.put(instr_map, :close, if :rand.uniform < uniform_close_mutation_rate do
          if :rand.uniform < close_increment_rate do # Rate at which to increase closes instead of decrease
            closes + 1
          else
            if closes <= 0 do
              0
            else
              closes - 1
            end
          end
          closes
        end)
      end
      new_genome = Enum.map(ind[:genome], close_mutator)
      make_individual(genome: new_genome,
                      history: ind[:history],
                      ancestors: if maintain_ancestors do
                        List.insert_at(ind[:ancestors], 0, ind[:genome])
                      else
                        ind[:ancestors]
                      end)
    else
      ind
    end
  end

  #############################################################################################
  ## uniform silence mutation

  @doc """
  Uniformly mutates the :silent's in the individual's instruction maps. Each
  :silent will have a uniform-silence-mutation-rate probability of being switched.
  """
  def uniform_silence_mutation(ind, args \\ []) do
    uniform_silence_mutation_rate = args[:uniform_silence_mutation_rate]
    epigenetic_markers = args[:epigenetic_markers]
    maintain_ancestors = args[:maintain_ancestors]
    if Enum.any?(epigenetic_markers, &(&1 == :silent)) do
      silent_mutator = fn(instr_map) ->
        silent = Map.get(instr_map, :silent, false)
        Map.put(instr_map, :silent, if :rand.uniform < uniform_silence_mutation_rate do
          not silent
        else
          silent
        end)
      end
      new_genome = Enum.map(ind[:genome], silent_mutator)
      make_individual(genome: new_genome,
                      history: ind[:history],
                      ancestors: if maintain_ancestors do
                        List.insert_at(ind[:ancestors], 0, ind[:genome])
                      else
                        ind[:ancestors]
                      end)
    else
      ind
    end
  end

  #############################################################################################
  ## uniform deletion

  @doc """
  Returns the individual with each element of its genome possibly deleted, with probability
  given by uniform-deletion-rate.
  """
  def uniform_deletion(ind, args \\ []) do
    uniform_deletion_rate = args[:uniform_deletion_rate]
    maintain_ancestors = args[:maintain_ancestors]
    new_genome = ind[:genome] |> Enum.map(&(if :rand.uniform < uniform_deletion_rate, do: &1, else: nil))
                              |> Enum.filter(&(&1))

    make_individual(genome: new_genome,
                    history: ind[:history],
                    ancestors: if maintain_ancestors do
                      List.insert_at(ind[:ancestors], 0, ind[:genome])
                    else
                      ind[:ancestors]
                    end)
  end
end
