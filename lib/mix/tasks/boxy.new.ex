defmodule Mix.Tasks.Boxy.New do
  @moduledoc """
  Creates a new Phoenix project with Boxy's opinionated defaults.

  Boxy enforces the following opinions:
    * LiveView is always enabled
    * PostgreSQL is always the database
    * Standard Phoenix project structure
    * CLAUDE.md files in every directory for Claude Code integration

  ## Usage

      $ mix boxy.new PATH [--module MODULE] [--app APP]

  All standard Phoenix options are supported and will be passed through.

  ## Examples

      $ mix boxy.new my_app
      $ mix boxy.new my_app --module MyCustomModule
      $ mix boxy.new my_app --no-mailer

  Note: The `--live` and `--database` flags are automatically set and cannot be overridden.
  """
  use Mix.Task

  @shortdoc "Creates a new Phoenix project with opinionated defaults (LiveView + PostgreSQL)"

  @impl Mix.Task
  def run(args) do
    # Enforce Boxy's opinions: always LiveView, always PostgreSQL
    opinionated_args = ["--live", "--database", "postgres" | args]

    # Run Phoenix generator
    Mix.Tasks.Phx.New.run(opinionated_args)

    # Extract the app path from args
    case extract_app_path(args) do
      {:ok, app_path} ->
        setup_boxy_features(app_path)

      :error ->
        # If we can't determine the path, skip post-processing
        :ok
    end
  end

  defp extract_app_path(args) do
    # The first non-flag argument is the app path
    case Enum.find(args, &(!String.starts_with?(&1, "-"))) do
      nil -> :error
      path -> {:ok, Path.expand(path)}
    end
  end

  defp setup_boxy_features(app_path) do
    if File.dir?(app_path) do
      copy_pedant_task(app_path)
      inject_precommit_alias(app_path)
      run_pedant(app_path)
    end
  end

  defp copy_pedant_task(app_path) do
    source = Path.join([__DIR__, "boxy.pedant.ex"])
    dest_dir = Path.join([app_path, "lib", "mix", "tasks"])
    dest_file = Path.join(dest_dir, "boxy.pedant.ex")

    File.mkdir_p!(dest_dir)
    File.cp!(source, dest_file)
    Mix.shell().info("* creating #{Path.relative_to_cwd(dest_file)}")
  end

  defp inject_precommit_alias(app_path) do
    mix_exs_path = Path.join(app_path, "mix.exs")
    content = File.read!(mix_exs_path)

    # Find the aliases function and inject precommit
    updated_content =
      String.replace(
        content,
        ~r/(defp aliases do\s+\[\s+)/,
        "\\1precommit: [\"boxy.pedant\"],\n      "
      )

    if content != updated_content do
      File.write!(mix_exs_path, updated_content)
      Mix.shell().info("* injecting #{Path.relative_to_cwd(mix_exs_path)} - precommit alias")
    end
  end

  defp run_pedant(app_path) do
    File.cd!(app_path, fn ->
      Mix.shell().info("\nRunning boxy.pedant to create CLAUDE.md files...")
      Mix.Tasks.Boxy.Pedant.run([])
    end)
  end
end
