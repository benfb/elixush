defmodule Elixush.Instructions.IO do
  alias Elixir.String
  import Elixush.PushState
  import Elixush.Util
  import Elixush.Globals.Agent

  def print_exec(state) do
    if Enum.empty?(state[:exec]) do
      state
    else
      top_thing = top_item(:exec, state)
      top_thing_string = Macro.to_string(top_thing)
      if get_globals(:max_string_length) < String.length(to_string(stack_ref(:output, 0, state)) <> top_thing_string) do
        state
      else
        stack_assoc(
          to_string(stack_ref(:output, 0, state)) <> top_thing_string,
          :output,
          0,
          pop_item(:exec, state)
        )
      end
    end
  end

  def print_integer(state) do
    if Enum.empty?(state[:integer]) do
      state
    else
      top_thing = top_item(:integer, state)
      top_thing_string = Macro.to_string(top_thing)
      if get_globals(:max_string_length) < String.length(to_string(stack_ref(:output, 0, state)) <> top_thing_string) do
        state
      else
        stack_assoc(
          to_string(stack_ref(:output, 0, state)) <> top_thing_string,
          :output,
          0,
          pop_item(:integer, state)
        )
      end
    end
  end

  def print_float(state) do
    if Enum.empty?(state[:float]) do
      state
    else
      top_thing = top_item(:float, state)
      top_thing_string = Macro.to_string(top_thing)
      if get_globals(:max_string_length) < String.length(to_string(stack_ref(:output, 0, state)) <> top_thing_string) do
        state
      else
        stack_assoc(
          to_string(stack_ref(:output, 0, state)) <> top_thing_string,
          :output,
          0,
          pop_item(:float, state)
        )
      end
    end
  end

  def print_code(state) do
    if Enum.empty?(state[:code]) do
      state
    else
      top_thing = top_item(:code, state)
      top_thing_string = Macro.to_string(top_thing)
      if get_globals(:max_string_length) < String.length(to_string(stack_ref(:output, 0, state)) <> top_thing_string) do
        state
      else
        stack_assoc(
          to_string(stack_ref(:output, 0, state)) <> top_thing_string,
          :output,
          0,
          pop_item(:code, state)
        )
      end
    end
  end

  def print_boolean(state) do
    if Enum.empty?(state[:boolean]) do
      state
    else
      top_thing = top_item(:boolean, state)
      top_thing_string = Macro.to_string(top_thing)
      if get_globals(:max_string_length) < String.length(to_string(stack_ref(:output, 0, state)) <> top_thing_string) do
        state
      else
        stack_assoc(
          to_string(stack_ref(:output, 0, state)) <> top_thing_string,
          :output,
          0,
          pop_item(:boolean, state)
        )
      end
    end
  end

  def print_string(state) do
    if Enum.empty?(state[:string]) do
      state
    else
      top_thing = top_item(:string, state)
      top_thing_string = Macro.to_string(top_thing)
      if get_globals(:max_string_length) < String.length(to_string(stack_ref(:output, 0, state)) <> top_thing_string) do
        state
      else
        stack_assoc(
          to_string(stack_ref(:output, 0, state)) <> top_thing_string,
          :output,
          0,
          pop_item(:string, state)
        )
      end
    end
  end

  def print_char(state) do
    if Enum.empty?(state[:char]) do
      state
    else
      top_thing = top_item(:char, state)
      top_thing_string = Macro.to_string(top_thing)
      if get_globals(:max_string_length) < String.length(to_string(stack_ref(:output, 0, state)) <> top_thing_string) do
        state
      else
        stack_assoc(
          to_string(stack_ref(:output, 0, state)) <> top_thing_string,
          :output,
          0,
          pop_item(:char, state)
        )
      end
    end
  end

  def print_vector_integer(state) do
    if Enum.empty?(state[:vector_integer]) do
      state
    else
      top_thing = top_item(:vector_integer, state)
      top_thing_string = Macro.to_string(top_thing)
      if get_globals(:max_string_length) < String.length(to_string(stack_ref(:output, 0, state)) <> top_thing_string) do
        state
      else
        stack_assoc(
          to_string(stack_ref(:output, 0, state)) <> top_thing_string,
          :output,
          0,
          pop_item(:vector_integer, state)
        )
      end
    end
  end

  def print_vector_float(state) do
    if Enum.empty?(state[:vector_float]) do
      state
    else
      top_thing = top_item(:vector_float, state)
      top_thing_string = Macro.to_string(top_thing)
      if get_globals(:max_string_length) < String.length(to_string(stack_ref(:output, 0, state)) <> top_thing_string) do
        state
      else
        stack_assoc(
          to_string(stack_ref(:output, 0, state)) <> top_thing_string,
          :output,
          0,
          pop_item(:vector_float, state)
        )
      end
    end
  end

  def print_vector_boolean(state) do
    if Enum.empty?(state[:vector_boolean]) do
      state
    else
      top_thing = top_item(:vector_boolean, state)
      top_thing_string = Macro.to_string(top_thing)
      if get_globals(:max_string_length) < String.length(to_string(stack_ref(:output, 0, state)) <> top_thing_string) do
        state
      else
        stack_assoc(
          to_string(stack_ref(:output, 0, state)) <> top_thing_string,
          :output,
          0,
          pop_item(:vector_boolean, state)
        )
      end
    end
  end

  def print_vector_string(state) do
    if Enum.empty?(state[:vector_string]) do
      state
    else
      top_thing = top_item(:vector_string, state)
      top_thing_string = Macro.to_string(top_thing)
      if get_globals(:max_string_length) < String.length(to_string(stack_ref(:output, 0, state)) <> top_thing_string) do
        state
      else
        stack_assoc(
          to_string(stack_ref(:output, 0, state)) <> top_thing_string,
          :output,
          0,
          pop_item(:vector_string, state)
        )
      end
    end
  end

  def print_newline(state) do
    if get_globals(:max_string_length) < (:output |> stack_ref(0, state) |> to_string) <> "\n" |> String.length do
      state
    else
      stack_assoc(to_string(stack_ref(:output, 0, state)) <> "\n", :output, 0, state)
    end
  end

  @doc """
  Allows Push to handle inN instructions, e.g. in2, using things from the input
  stack. We can tell whether a particular inN instruction is valid if N-1
  values are on the input stack. Recognizes vectors, simple literals and quoted code.
  """
  def handle_input_instruction(instr, state) do
    n = ~r/in(\d+)/ |> Regex.run(Atom.to_string(instr)) |> Enum.at(1) |> String.to_integer
    if n > length(state[:input]) or n < 1 do
      raise(ArgumentError, message: "Undefined instruction: #{instr} \nNOTE: Likely not same number of items on input stack as input instructions.")
    else
      item = stack_ref(:input, n - 1, state)
      literal_type = recognize_literal(item)
      cond do
        is_list(item) && item == [] -> push_item([], :vector_integer, push_item([], :vector_float, push_item([], :vector_string, push_item([], :vector_boolean, state))))
        is_tuple(item) -> push_item(item, :exec, state)
        true -> push_item(item, literal_type, state)
      end
    end
  end
end
