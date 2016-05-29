defmodule Elixush.Instructions.Genome do
  @moduledoc "Instructions that operate on the genome stack."
  import Elixush.Globals.Agent
  import Elixush.PushState

  def genome_gene_dup(state) do
    if (not(Enum.empty?(state[:integer])) and not(Enum.empty?(state[:genome]))) and (not(Enum.empty?(stack_ref(:genome, 0, state))) and length(hd(state[:genome])) < (get_globals(:global_max_points) / 2)) do
      genome = stack_ref(:genome, 0, state)
      index = rem(stack_ref(:integer, 0, state), length(genome))
      push_item(Enum.concat(Enum.take(genome, index + 1), Enum.drop(genome, index)), :genome, pop_item(:genome, pop_item(:integer, state)))
    else
      state
    end
  end

  # def genome_gene_randomize(state) do
  #   if (not(Enum.empty?(state[:integer])) and not(Enum.empty?(state[:genome]))) and not(Enum.empty?(stack_ref(:genome, 0, state))) do
  #     genome = stack_ref(:genome, 0, state)
  #     index = rem(stack_ref(:integer, 0, state), length(genome))
  #     push_item(Enum.concat(Enum.take(genome, index + 1), Enum.drop(genome, index)), :genome, pop_item(:genome, pop_item(:integer, state)))
  #   else
  #     state
  #   end
  # end

  def genome_gene_delete(state) do
    if (not(Enum.empty?(state[:integer])) and not(Enum.empty?(state[:genome]))) and not(Enum.empty?(stack_ref(:genome, 0, state))) do
      genome = stack_ref(:genome, 0, state)
      index = rem(stack_ref(:integer, 0, state), length(genome))
      push_item(Enum.concat(Enum.take(genome, index), Enum.drop(genome, index + 1)), :genome, pop_item(:genome, pop_item(:integer, state)))
    else
      state
    end
  end

  def genome_rotate(state) do
    if (not(Enum.empty?(state[:integer])) and not(Enum.empty?(state[:genome]))) and not(Enum.empty?(stack_ref(:genome, 0, state))) do
      genome = stack_ref(:genome, 0, state)
      distance = rem(stack_ref(:integer, 0, state), length(genome))
      push_item(Enum.concat(Enum.drop(genome, distance), Enum.take(genome, distance)), :genome, pop_item(:genome, pop_item(:integer, state)))
    else
      state
    end
  end

  # TODO: Mostly done
  # def genome_gene_copy(state) do
  #   if (not(Enum.empty?(state[:integer])) and not(Enum.empty?(state[:genome]))) and not(Enum.empty?(stack_ref(:genome, 1, state))) do
  #     source = stack_ref(:genome, 1, state)
  #     destination = stack_ref(:genome, 0, state)
  #     index = rem(stack_ref(:integer, 0, state), length(source))
  #     push_item(Enum.concat(Enum.drop(genome, distance), Enum.take(genome, distance)), :genome, pop_item(:genome, pop_item(:integer, state)))
  #   else
  #     state
  #   end
  # end

  def genome_new(state) do
    push_item({}, :genome, state)
  end

  def genome_parent1(state) do
    push_item(state[:parent1_genome], :genome, state)
  end

  def genome_parent2(state) do
    push_item(state[:parent2_genome], :genome, state)
  end

  def autoconstructive_integer_rand(state) do
    # pushes a constant integer, but is replaced with integer_rand during
    # nondetermistic autoconstruction
    push_item(0, :integer, state)
  end

  def autoconstructive_boolean_rand(state) do
    # pushes false, but is replaced with boolean_rand during
    # nondetermistic autoconstruction
    push_item(false, :boolean, state)
  end

end
