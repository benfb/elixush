# Elixush

An Elixir-based interpreter for the Push genetic programming language.
The result is a minimalist, simply-implemented Push interpreter.

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

    Compiled lib/elixush.ex

    iex(1)> Elixush.Server.run_program [1, 2, :integer_sub]

    %{auxiliary: [], boolean: [], char: [], code: [], environment: [], exec: [],
      float: [], genome: [], input: [], integer: [-1], output: [], return: [],
      string: [], tag: [], termination: :normal, vector_boolean: [],
      vector_float: [], vector_integer: [], vector_string: [], zip: []}

## Getting Started

To run Elixush, you'll need to install Elixir. The official instructions for how
to do so can be found [here](http://elixir-lang.org/install.html). If you have a
Mac, a simple `brew install elixir` should suffice.

Installing the Elixir language also installs the Erlang virtual machine, as well
as Elixir's interactive shell (REPL), IEx. Once Elixir is installed, you can run
`iex -S mix` in the Elixush directory and it will start up a REPL with Elixush
loaded in.

## Roadmap

* Clean up codebase
* Finish porting over instructions from Clojush
* Add tests!
* Make a standalone executable?
