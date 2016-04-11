defmodule Elixush.GP.Report do
  def default_problem_specific_report(_best, _population, _generation, _error_function, _report_simplifications) do
    :no_problem_specific_report_function_defined
  end
end
