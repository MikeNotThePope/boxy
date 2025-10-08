defmodule Mix.Tasks.Boxy.New do
  @moduledoc """
  Creates a new Phoenix project with Boxy's opinionated defaults.

  Boxy enforces the following opinions:
    * LiveView is always enabled
    * PostgreSQL is always the database
    * Standard Phoenix project structure
    * CLAUDE.md files in every directory for Claude Code integration
    * Git pre-commit hook that ensures CLAUDE.md files and passing tests
    * Minimal blank homepage (replaces Phoenix marketing page)

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
      ensure_git_initialized(app_path)
      install_git_hook(app_path)
      replace_homepage(app_path)
      replace_homepage_test(app_path)
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

  defp ensure_git_initialized(app_path) do
    git_dir = Path.join(app_path, ".git")

    unless File.dir?(git_dir) do
      File.cd!(app_path, fn ->
        System.cmd("git", ["init"], into: IO.stream(:stdio, :line))
      end)
    end
  end

  defp install_git_hook(app_path) do
    git_hooks_dir = Path.join([app_path, ".git", "hooks"])

    if File.dir?(git_hooks_dir) do
      priv_dir = :code.priv_dir(:boxy) |> to_string()
      hook_source = Path.join([priv_dir, "templates", "pre-commit"])
      hook_dest = Path.join(git_hooks_dir, "pre-commit")

      File.cp!(hook_source, hook_dest)
      File.chmod!(hook_dest, 0o755)
      Mix.shell().info("* installing .git/hooks/pre-commit")
    end
  end

  defp replace_homepage(app_path) do
    # Find the homepage template (pattern: lib/*_web/controllers/page_html/home.html.heex)
    homepage_pattern =
      Path.join([app_path, "lib", "*_web", "controllers", "page_html", "home.html.heex"])

    case Path.wildcard(homepage_pattern) do
      [homepage_path | _] ->
        priv_dir = :code.priv_dir(:boxy) |> to_string()
        template_source = Path.join([priv_dir, "templates", "home.html.heex"])

        File.cp!(template_source, homepage_path)
        Mix.shell().info("* replacing #{Path.relative_to_cwd(homepage_path)}")

      [] ->
        Mix.shell().info("Warning: Could not find homepage template to replace")
    end
  end

  defp replace_homepage_test(app_path) do
    # Find the test file (pattern: test/*_web/controllers/page_controller_test.exs)
    test_pattern =
      Path.join([app_path, "test", "*_web", "controllers", "page_controller_test.exs"])

    case Path.wildcard(test_pattern) do
      [test_path | _] ->
        # Determine the web module name from the app path
        app_name =
          app_path
          |> Path.basename()
          |> Macro.camelize()

        web_module_name = "#{app_name}Web"

        priv_dir = :code.priv_dir(:boxy) |> to_string()
        template_source = Path.join([priv_dir, "templates", "page_controller_test.exs"])
        template_content = File.read!(template_source)

        # Replace MODULE_NAME with the actual web module name
        content = String.replace(template_content, "MODULE_NAME", web_module_name)

        File.write!(test_path, content)
        Mix.shell().info("* replacing #{Path.relative_to_cwd(test_path)}")

      [] ->
        Mix.shell().info("Warning: Could not find page_controller_test.exs to replace")
    end
  end

  defp run_pedant(app_path) do
    File.cd!(app_path, fn ->
      Mix.shell().info("\nRunning boxy.pedant to create CLAUDE.md files...")
      Mix.Tasks.Boxy.Pedant.run([])
    end)
  end
end
