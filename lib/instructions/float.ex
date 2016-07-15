defmodule Elixush.Instructions.Float do
  @moduledoc "Instructions that operate on the float stack."
  import Elixush.PushState
  import Elixush.Util

  @doc "Pushes the sum of the top two items."
  def float_add(%{float: float} = state) when length(float) >= 2 do
    first = stack_ref(:float, 0, state)
    second = stack_ref(:float, 1, state)
    first
    |> (fn(x) -> x + second end).()
    |> keep_number_reasonable
    |> push_item(:float, pop_item(:float, pop_item(:float, state)))
  end

  def float_add(state), do: state

  @doc "Pushes the difference of the top two items."
  def float_sub(%{float: float} = state) when length(float) >= 2 do
    first = stack_ref(:float, 0, state)
    second = stack_ref(:float, 1, state)
    second
    |> (fn(x) -> x - first end).()
    |> keep_number_reasonable
    |> push_item(:float, pop_item(:float, pop_item(:float, state)))
  end

  def float_sub(state), do: state

  @doc "Pushes the product of the top two items."
  def float_mult(%{float: float} = state) when length(float) >= 2 do
    first = stack_ref(:float, 0, state)
    second = stack_ref(:float, 1, state)
    item =
      second
      |> (fn(x) -> x * first end).()
      |> keep_number_reasonable
    push_item(item, :float, pop_item(:float, pop_item(:float, state)))
  end

  def float_mult(state), do: state

  @doc "Returns a function that pushes the product of the top two items."
  def float_div(%{float: float} = state) when length(float) >= 2 and hd(float) != 0 do
    first = stack_ref(:float, 0, state)
    second = stack_ref(:float, 1, state)
    item =
      second
      |> (fn(x) -> x / first end).()
      |> keep_number_reasonable
    push_item(item, :float, pop_item(:float, pop_item(:float, state)))
  end

  def float_div(state), do: state

  # @doc """
  # Returns a function that pushes the modulus of the top two items. Does
  # nothing if the denominator would be zero.
  # """
  # def float_mod(state) do
  #   if not(Enum.empty?(Enum.drop(state[:float], 1))) and not(stack_ref(:float, 0, state) == 0) do
  #     first = stack_ref(:float, 0, state)
  #     second = stack_ref(:float, 1, state)
  #     item = second |> rem(first) |> keep_number_reasonable
  #     push_item(item, :float, pop_item(:float, pop_item(:float, state)))
  #   else
  #     state
  #   end
  # end

  ### Comparers

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':float' stack onto the boolean stack.
  """
  def float_lt(%{float: float} = state) when length(float) >= 2 do
    first = stack_ref(:float, 0, state)
    second = stack_ref(:float, 1, state)
    item = second < first
    push_item(item, :boolean, pop_item(:float, pop_item(:float, state)))
  end

  def float_lt(state), do: state

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':float' stack onto the boolean stack.
  """
  def float_lte(%{float: float} = state) when length(float) >= 2 do
    first = stack_ref(:float, 0, state)
    second = stack_ref(:float, 1, state)
    item = second <= first
    push_item(item, :boolean, pop_item(:float, pop_item(:float, state)))
  end

  def float_lte(state), do: state

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':float' stack onto the boolean stack.
  """
  def float_gt(%{float: float} = state) when length(float) >= 2 do
    first = stack_ref(:float, 0, state)
    second = stack_ref(:float, 1, state)
    item = second > first
    push_item(item, :boolean, pop_item(:float, pop_item(:float, state)))
  end

  def float_gt(state), do: state

  @doc """
  Returns a function that pushes the result of comparator of the top two items
  on the ':float' stack onto the boolean stack.
  """
  def float_gte(%{float: float} = state) when length(float) >= 2 do
    first = stack_ref(:float, 0, state)
    second = stack_ref(:float, 1, state)
    item = second >= first
    push_item(item, :boolean, pop_item(:float, pop_item(:float, state)))
  end

  def float_gte(state), do: state

  def float_fromboolean(%{boolean: bool} = state) when length(bool) >= 1 do
    item = stack_ref(:boolean, 0, state)
    to_push = if item do 1.0 else 0.0 end
    push_item(to_push, :float, pop_item(:boolean, state))
  end

  def float_fromboolean(state), do: state

  def float_frominteger(%{integer: int} = state) when length(int) >= 1 do
    item = stack_ref(:integer, 0, state)
    push_item(item * 1.0, :float, pop_item(:integer, state))
  end

  def float_frominteger(state), do: state

  # TODO: make this exit more gracefully
  def float_fromstring(%{string: str} = state) when length(str) >= 1 do
    try do
      pop_item(:string, push_item(:string
                                  |> top_item(state)
                                  |> String.to_float
                                  |> keep_number_reasonable, :float, state))
    rescue
      _error in ArgumentError -> state
    end
  end

  def float_fromstring(state), do: state

  # TODO: Add float_fromchar

  @doc "Returns a function that pushes the minimum of the top two items."
  def float_min(%{float: float} = state) when length(float) >= 2 do
    first = stack_ref(:float, 0, state)
    second = stack_ref(:float, 1, state)
    second
    |> min(first)
    |> push_item(:float, pop_item(:float, pop_item(:float, state)))
  end

  def float_min(state), do: state

  @doc "Returns a function that pushes the maximum of the top two items."
  def float_max(%{float: float} = state) when length(float) >= 2 do
    first = stack_ref(:float, 0, state)
    second = stack_ref(:float, 1, state)
    second
    |> max(first)
    |> push_item(:float, pop_item(:float, pop_item(:float, state)))
  end

  def float_max(state), do: state

  def float_sin(%{float: float} = state) when length(float) >= 1 do
    :float
    |> stack_ref(0, state)
    |> :math.sin
    |> keep_number_reasonable
    |> push_item(:float, pop_item(:float, state))
  end

  def float_sin(state), do: state

  def float_cos(%{float: float} = state) when length(float) >= 1 do
    :float
    |> stack_ref(0, state)
    |> :math.cos
    |> keep_number_reasonable
    |> push_item(:float, pop_item(:float, state))
  end

  def float_cos(state), do: state

  def float_tan(%{float: float} = state) when length(float) >= 1 do
    :float
    |> stack_ref(0, state)
    |> :math.tan
    |> keep_number_reasonable
    |> push_item(:float, pop_item(:float, state))
  end

  def float_tan(state), do: state

  def float_inc(%{float: float} = state) when length(float) >= 1 do
    :float
    |> stack_ref(0, state)
    |> (fn(x) -> x + 1.0 end).()
    |> keep_number_reasonable
    |> push_item(:float, pop_item(:float, state))
  end

  def float_inc(state), do: state

  def float_dec(%{float: float} = state) when length(float) >= 1 do
    :float
    |> stack_ref(0, state)
    |> (fn(x) -> x - 1.0 end).()
    |> keep_number_reasonable
    |> push_item(:float, pop_item(:float, state))
  end

  def float_dec(state), do: state
end
