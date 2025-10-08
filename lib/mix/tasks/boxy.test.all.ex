defmodule Mix.Tasks.Boxy.Test.All do
  @moduledoc """
  Runs both Boxy's test suite and the test app's test suite via the test app's test alias.

  This task is useful during development to ensure that changes to Boxy
  don't break the generated test application in tmp/test_app.

  ## Usage

      $ mix boxy.test.all

  The task will:
    1. Ensure tmp/test_app exists (creating it if needed)
    2. Run `mix test` in the test app directory
    3. The test app's `test` alias runs both Boxy's tests and the test app's tests

  ## Exit Codes

  - 0: All tests passed
  - 1: Tests failed or test app creation failed
  """
  use Mix.Task

  @shortdoc "Runs Boxy test app tests"

  @impl Mix.Task
  def run(_args) do
    test_app_path = Path.join([File.cwd!(), "tmp", "test_app"])

    unless File.dir?(test_app_path) do
      Mix.shell().info("Test app not found. Creating tmp/test_app...")

      case System.cmd("mix", ["boxy.new", "tmp/test_app", "--install"],
             into: IO.stream(:stdio, :line)
           ) do
        {_, 0} ->
          Mix.shell().info("\n✓ Test app created")

        {_, _} ->
          Mix.shell().error("\n✗ Failed to create test app")
          exit({:shutdown, 1})
      end
    end

    Mix.shell().info("\nRunning tests via test app (#{test_app_path})...")

    case System.cmd("mix", ["test"], cd: test_app_path, into: IO.stream(:stdio, :line)) do
      {_, 0} ->
        Mix.shell().info("\n✓✓ All tests passed!")

      {_, _} ->
        Mix.shell().error("\n✗ Tests failed")
        exit({:shutdown, 1})
    end
  end
end
