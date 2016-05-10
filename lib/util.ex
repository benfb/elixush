defmodule Elixush.Util do
  import Elixush.Globals.Agent

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

  @doc "really make-list-if-not-seq, but close enough for here"
  def ensure_list(thing) do
    if is_list(thing) do
      thing
    else
      # REVIEW: Is just Enum.to_list sufficient here?
      Enum.to_list(thing)
    end
  end

  @doc "Prints the provided thing and returns it."
  def print_return(thing) do
    IO.puts(Macro.to_string(thing))
    thing
  end

  @doc "Returns a version of n that obeys limit parameters."
  @spec keep_number_reasonable(number) :: number
  def keep_number_reasonable(n) do
    max_number_magnitude = get_globals(:max_number_magnitude)
    cond do
      is_integer(n) ->
        cond do
          n > max_number_magnitude -> max_number_magnitude
          n < -max_number_magnitude -> -max_number_magnitude
          true -> n
        end
      true ->
        cond do
          n > max_number_magnitude -> max_number_magnitude * 1.0
          n < -max_number_magnitude -> -max_number_magnitude * 1.0
          n < -max_number_magnitude and n > max_number_magnitude -> 0.0
          true -> n
        end
    end
  end

  @doc "If a number, rounds float f to n decimal places."
  def round_to_n_decimal_places(f, n) do
    if !is_number(f) do
      f
    else
      factor = :math.pow(10, n)
      round(f * factor) / factor
    end
  end

  @doc "Returns the number of paren pairs in tree"
  @spec count_parens(Enum.t) :: integer
  def count_parens(tree) do
    # HACK: anonymous functions used to emulate loop/recur from clojure
    loop = fn(f, remaining, total) ->
      cond do
        not is_list(remaining) -> total
        Enum.empty?(remaining) -> total + 1
        not is_list(hd(remaining)) -> f.(f, tl(remaining), total)
        true -> f.(f, remaining, total + 1)
      end
    end
    loop.(loop, tree, 0)
  end

  @doc """
  Returns the number of points in tree, where each atom and each pair of parentheses
  counts as a point.
  """
  @spec count_points(Enum.t) :: integer
  def count_points(tree) do
    # HACK: anonymous functions used to emulate loop/recur from clojure
    loop = fn(f, remaining, total) ->
      cond do
        not is_list(remaining) -> total + 1
        Enum.empty?(remaining) -> total + 1
        not is_list(hd(remaining)) -> f.(f, tl(remaining), total + 1)
        true -> f.(f, remaining, total + 1)
      end
    end
    loop.(loop, tree, 0)
  end

  @doc "Returns a subtree of tree indexed by point-index in a depth first traversal."
  def code_at_point(tree, point_index) do
    index = point_index |> abs |> rem(count_points(tree))
    zipper = :zipper_default.list(tree) # TODO: check that this is the right function
    loop = fn(f, z, i) ->
      if i == 0, do: :zipper.node(z), else: f.(f, :zipper.next(z), i - 1)
    end
    loop.(loop, zipper, index)
  end

  @doc """
  Returns a copy of tree with the subtree formerly indexed by
  point_index (in a depth-first traversal) replaced by new_subtree.
  """
  def insert_code_at_point(tree, point_index, new_subtree) do
    index = point_index |> abs |> rem(count_points(tree))
    zipper = :zipper_default.list(tree) # TODO: check that this is the right function
    loop = fn(f, z, i) ->
      if i == 0, do: :zipper.root(:zipper.replace(z, new_subtree)), else: f.(f, :zipper.next(z), i - 1)
    end
    loop.loop(zipper, index)
  end

  @doc "Like walk, but only for lists."
  def walklist(inner, outer, form) do
    if is_list(form) do
      outer.(Enum.map(form, inner))
    else
      outer.(form)
    end
  end

  @doc "Like postwalk, but only for lists"
  # REVIEW: check that this works correctly
  def postwalklist(f, form) do
    walklist(&(postwalklist(f, &1)), f, form)
  end

  @doc "Like postwalk-replace, but only for lists"
  def postwalklist_replace(smap, form) do # TODO: is this valid syntax?
    postwalklist(&(if Map.has_key?(smap, &1), do: Map.get(smap, &1), else: &1), form)
  end

  @doc """
  Returns the given list but with all instances of that (at any depth)
  replaced with this. Read as 'subst this for that in list'.
  """
  def subst(this, that, lst) do
    postwalklist_replace(Map.new([{that, this}]), lst)
  end

  @doc """
  Returns true if tree contains subtree at any level. Inefficient but
  functional implementation.
  """
  def contains_subtree(tree, subtree) do # TODO: what does gensym do here?
    tree == subtree or not(tree == subst(:gensym, subtree, tree))
  end

  @doc """
  If tree contains subtree at any level then this returns the smallest
  subtree of tree that contains but is not equal to the first instance of
  subtree. For example, contining-subtree([b [c [a]] [d [a]]], [a]]) => [c [a]].
  Returns nil if tree does not contain subtree.
  """
  def containing_subtree(tree, subtree) do
    cond do
      not(is_list(tree)) -> nil
      Enum.empty?(tree) -> nil
      Enum.member?(tree, subtree) -> tree
      true -> some(tree, &(containing_subtree(&1, subtree)))
    end
  end

  ## some

  def some(enumerable, fun) when is_list(enumerable) do
    do_some(enumerable, fun)
  end

  defp do_some([h|t], fun) do
    if fun.(h) do
      h
    else
      do_some(t, fun)
    end
  end

  defp do_some([], _) do
    false
  end

  # TODO: insert-code-at-point, remove-code-at-point

  @doc "computes the next row using the prev-row current-element and the other seq"
  def compute_next_row(prev_row, current_element, other_seq, pred) do
    Enum.reduce(List.zip([prev_row, Enum.fetch(prev_row, 1), other_seq]), (hd(prev_row) + 1),
    fn(row, [diagonal, above, other_element]) ->
      update_val = if pred.(other_element, current_element) do
        # if the elements are deemed equivalent according to the predicate
        # pred, then no change has taken place to the string, so we are
        # going to set it the same value as diagonal (which is the previous edit-distance)
        diagonal
      else
        # in the case where the elements are not considered equivalent, then we are going
        # to figure out if its a substitution (then there is a change of 1 from the previous
        # edit distance) thus the value is diagonal + 1 or if its a deletion, then the value
        # is present in the columns, but not in the rows, the edit distance is the edit-distance
        # of last of row + 1 (since we will be using vectors, peek is more efficient)
        # or it could be a case of insertion, then the value is above+1, and we chose
        # the minimum of the three
        Enum.min([diagonal, above, hd(row)]) + 1
      end
      List.insert_at(row, 0, update_val)
    end)
  end

  @doc """
  Levenshtein Distance - http://en.wikipedia.org/wiki/Levenshtein_distance
    In information theory and computer science, the Levenshtein distance is a
    metric for measuring the amount of difference between two sequences. This
    is a functional implementation of the levenshtein edit
    distance with as little mutability as possible.
    Still maintains the O(n*m) guarantee.
  """
  def levenshtein_distance(a, b, p) do
    cond do
      List.empty? a -> length b
      List.empty? b -> length a
      true -> Enum.reduce()
      fn(prev_row, current_element) ->
        compute_next_row(prev_row, current_element, b, p)
      end
      Range.new(0, length(b) + 1)
    end
  end
end
