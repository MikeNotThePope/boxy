defmodule Mix.Tasks.Boxy.TestBoxy do
  @moduledoc """
  Runs only Boxy's test suite by directly invoking ExUnit.

  This task exists to allow the `test` alias to run both Boxy tests and
  test app tests without recursion issues.

  ## Usage

      $ mix boxy.test_boxy

  This is equivalent to running `mix test` but can be used in an alias
  without causing infinite recursion.
  """
  use Mix.Task

  @shortdoc "Runs Boxy tests only"
  @recursive true

  @impl Mix.Task
  def run(args) do
    # Start the application and dependencies
    Mix.Task.run("loadpaths", args)
    Mix.Task.run("compile", args)

    # Start ExUnit
    ExUnit.start()

    # Load test files
    test_paths = ["test"]
    test_pattern = "**/*_test.exs"

    Enum.each(test_paths, fn path ->
      Path.wildcard(Path.join(path, test_pattern))
      |> Enum.each(&Code.require_file/1)
    end)

    # Run ExUnit
    ExUnit.run()
  end
end
