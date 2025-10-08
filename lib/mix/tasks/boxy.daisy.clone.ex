defmodule Mix.Tasks.Boxy.Daisy.Clone do
  @moduledoc """
  Clones the DaisyUI repository into the tmp directory.

  This task clones a shallow copy (depth 1) of the DaisyUI repository from GitHub
  into `tmp/daisyui`. If the directory already exists, it will be deleted first.

  ## Usage

      $ mix boxy.daisy.clone

  The task will:
    1. Delete tmp/daisyui if it already exists
    2. Clone git@github.com:saadeghi/daisyui.git with --depth 1

  ## Exit Codes

  - 0: Clone succeeded
  - 1: Clone failed
  """
  use Mix.Task

  @shortdoc "Clones DaisyUI repository into tmp directory"

  @impl Mix.Task
  def run(_args) do
    tmp_dir = Path.join([File.cwd!(), "tmp"])
    daisyui_path = Path.join(tmp_dir, "daisyui")

    # Ensure tmp directory exists
    File.mkdir_p!(tmp_dir)

    # Delete existing daisyui directory if it exists
    if File.dir?(daisyui_path) do
      Mix.shell().info("Removing existing daisyui directory...")
      File.rm_rf!(daisyui_path)
      Mix.shell().info("✓ Removed #{Path.relative_to_cwd(daisyui_path)}")
    end

    # Clone the repository
    Mix.shell().info("Cloning DaisyUI repository (depth 1)...")

    case System.cmd("git", ["clone", "--depth", "1", "git@github.com:saadeghi/daisyui.git"],
           cd: tmp_dir,
           into: IO.stream(:stdio, :line)
         ) do
      {_, 0} ->
        Mix.shell().info(
          "\n✓ DaisyUI cloned successfully to #{Path.relative_to_cwd(daisyui_path)}"
        )

      {_, _} ->
        Mix.shell().error("\n✗ Failed to clone DaisyUI repository")
        exit({:shutdown, 1})
    end
  end
end
