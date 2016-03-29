defmodule Exush.Individual do
  def make_individual do
    %{
      genome: nil,
      program: nil,
      errors: nil,
      total_error: nil, # a non-number is used to indicate no value
      normalized_error: nil,
      weighted_error: nil,
      meta_errors: nil,
      history: nil,
      ancestors: nil,
      uuid: UUID.uuid4(:weak),
      parent_uuids: nil,
      genetic_operators: nil
    }
  end

end
