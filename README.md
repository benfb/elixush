# Elixush

An Elixir-based interpreter for the [Push genetic programming language](http://pushlanguage.org).
The result is a minimalist, simply-implemented Push interpreter.

## Installation

The package can be installed as:

  1. Add elixush to your list of dependencies in `mix.exs`:

        def deps do
          [{:elixush, "~> 0.0.4"}]
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
as Elixir's interactive shell (REPL), IEx. Once Elixir is installed, run `mix deps.get`
to install the requisite dependencies, then `mix deps.compile` to compile them.
You can then run `iex -S mix` in the Elixush directory and it will start up a REPL
with Elixush loaded in.

Elixush includes a "Server" that takes Push programs as lists of instructions.
This server can be accessed by calling `Elixush.Server.run_program` from the REPL,
followed by a list of instructions, such as `Elixush.Server.run_program [1, 2, :integer_add]`.
This will print out the stack state at the end of the program's execution, or in
this case the following map:
```
%{auxiliary: [], boolean: [], char: [], code: [], environment: [], exec: [],
  float: [], genome: [], input: [], integer: [3], output: [], return: [],
  string: [], tag: [], termination: :normal, vector_boolean: [],
  vector_float: [], vector_integer: [], vector_string: [], zip: []}
```

If the program crashes the server for some reason, a Supervisor will simply restart
the server process in the background, following Elixir's let-it-crash mentality.
The REPL process can be exited by pressing `CTRL-C` twice.

## Reasoning

Elixir runs every function in its own process on the virtual machine. The Elixir
virtual machine has a much faster startup time than the JVM. The well-established
OTP architecture in place here makes concurrency and parallelism much easier to
implement than in Clojush. By focusing only on the interpreter rather than actual
genetic programming, Elixush is much easier to maintain. Elixir conventions are
generally followed, making the code relatively easy to understand at a glance. The
way the interpreter is structured makes it easy to add new instructions and types.
The project also attempts to widen Push's audience, as it opens up Push to the Elixir
community. Theoretically, Elixush *should* run better on clusters than Clojush, but
some testing is still necessary.

## Roadmap

* Clean up codebase
* Finish porting over instructions from Clojush
* Improve tests
* Make a standalone executable?
* Implement GP?
* Implement Plush?

## Publishing

* Bump version number in `mix.exs` and `README.md`
* `mix hex.publish`
* `mix hex.docs`
