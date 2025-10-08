defmodule Mix.Tasks.Boxy.TestApp do
  @moduledoc """
  Runs only the test app's test suite (without Boxy tests).

  This task is designed to be used in a test alias to run both Boxy tests
  and test app tests sequentially without recursion.

  ## Usage

      $ mix boxy.test_app

  The task will:
    1. Ensure tmp/test_app exists (creating it if needed)
    2. Run only the test app's own tests (not Boxy's tests)

  ## Exit Codes

  - 0: All tests passed
  - 1: Tests failed or test app creation failed
  """
  use Mix.Task

  @shortdoc "Runs test app tests only (not Boxy tests)"

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

    Mix.shell().info("\nRunning test app tests only...")

    # Run only the test app's tests (not Boxy's tests)
    case System.cmd("mix", ["test", "test/"],
           cd: test_app_path,
           into: IO.stream(:stdio, :line)
         ) do
      {_, 0} ->
        Mix.shell().info("\n✓ Test app tests passed!")

      {_, _} ->
        Mix.shell().error("\n✗ Test app tests failed")
        exit({:shutdown, 1})
    end
  end
end
