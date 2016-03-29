# Elixush

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add elixush to your list of dependencies in `mix.exs`:

        def deps do
          [{:elixush, "~> 0.0.1"}]
        end

  2. Ensure elixush is started before your application:

        def application do
          [applications: [:elixush]]
        end

## Running

For now, the best way to run Push programs is IEx:

        $ iex -S mix
        iex(1)> Elixush.Server.run_program [1, 2, :integer_sub]
        %{auxiliary: [], boolean: [], char: [], code: [], environment: [], exec: [],
          float: [], genome: [], input: [], integer: [-1], output: [], return: [],
          string: [], tag: [], termination: :normal, vector_boolean: [],
          vector_float: [], vector_integer: [], vector_string: [], zip: []}
