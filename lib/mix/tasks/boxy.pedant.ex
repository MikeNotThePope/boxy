defmodule Mix.Tasks.Boxy.Pedant do
  @moduledoc """
  Ensures every non-gitignored directory has a CLAUDE.md file.

  This task scans all directories in your project and creates an empty
  CLAUDE.md file in any directory that:
    * Is not ignored by .gitignore
    * Does not already have a CLAUDE.md file

  ## Usage

      $ mix boxy.pedant

  This task is typically run as part of a pre-commit workflow to ensure
  Claude Code has context files in all relevant directories.
  """
  use Mix.Task

  @shortdoc "Ensures every directory has a CLAUDE.md file"

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("Scanning directories for missing CLAUDE.md files...")

    project_root = File.cwd!()
    directories = find_all_directories(project_root)

    non_ignored_dirs =
      directories
      |> Enum.filter(&not_gitignored?/1)

    created_count =
      non_ignored_dirs
      |> Enum.map(&ensure_claude_md/1)
      |> Enum.count(& &1)

    if created_count > 0 do
      Mix.shell().info("Created #{created_count} CLAUDE.md file(s)")
    else
      Mix.shell().info("All directories already have CLAUDE.md files")
    end
  end

  defp find_all_directories(root) do
    Path.wildcard(Path.join(root, "**"), match_dot: true)
    |> Enum.filter(&File.dir?/1)
  end

  defp not_gitignored?(path) do
    # Skip .git directory and its subdirectories
    if String.contains?(path, "/.git") or String.ends_with?(path, "/.git") do
      false
    else
      case System.cmd("git", ["check-ignore", path], stderr_to_stdout: true) do
        # Not ignored (exit code 1)
        {_, 1} -> true
        # Ignored (exit code 0)
        {_, 0} -> false
        # If git isn't available, include it
        _ -> true
      end
    end
  end

  defp ensure_claude_md(directory) do
    claude_md_path = Path.join(directory, "CLAUDE.md")

    if File.exists?(claude_md_path) do
      false
    else
      File.write!(claude_md_path, "")
      Mix.shell().info("  * creating #{Path.relative_to_cwd(claude_md_path)}")
      true
    end
  end
end
