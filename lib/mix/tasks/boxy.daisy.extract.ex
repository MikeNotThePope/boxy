defmodule Mix.Tasks.Boxy.Daisy.Extract do
  @moduledoc """
  Extracts HTML examples from DaisyUI component documentation.

  This task scans all markdown files in the DaisyUI components directory
  and extracts title-HTML example pairs from each file.

  ## Usage

      $ mix boxy.daisy.extract

  The task will:
    1. Find all markdown files in tmp/daisyui/packages/docs/src/routes/(routes)/components
    2. Parse each file to extract sections with titles (### ~Title) and HTML examples
    3. Return a list of tuples: [{title, html_example}, ...]

  ## Output

  The extracted data is printed to stdout in Elixir term format, which can be
  evaluated or written to a file for further processing.
  """
  use Mix.Task

  @shortdoc "Extracts HTML examples from DaisyUI component docs"

  @impl Mix.Task
  def run(_args) do
    components_dir =
      Path.join([
        File.cwd!(),
        "tmp",
        "daisyui",
        "packages",
        "docs",
        "src",
        "routes",
        "(routes)",
        "components"
      ])

    unless File.dir?(components_dir) do
      Mix.shell().error(
        "Components directory not found: #{components_dir}\n" <>
          "Run `mix boxy.daisy.clone` first to clone the DaisyUI repository."
      )

      exit({:shutdown, 1})
    end

    Mix.shell().info("Extracting HTML examples from DaisyUI components...")

    markdown_files = find_markdown_files(components_dir)
    Mix.shell().info("Found #{length(markdown_files)} markdown file(s)")

    examples =
      markdown_files
      |> Enum.flat_map(&extract_examples_from_file/1)

    Mix.shell().info("\nExtracted #{length(examples)} example(s) total\n")
    Mix.shell().info("Examples by title:\n")

    # Print summary
    examples
    |> Enum.group_by(fn {title, _} -> title end)
    |> Enum.each(fn {title, examples} ->
      Mix.shell().info("  #{title}: #{length(examples)} example(s)")
    end)

    Mix.shell().info("\n✓ Extraction complete")
    Mix.shell().info("\nReturning data structure...")

    # Return the examples as Elixir terms
    examples |> Enum.sort() |> Enum.each(&IO.inspect/1)
  end

  defp find_markdown_files(dir) do
    Path.join(dir, "**/*.md")
    |> Path.wildcard()
    |> Enum.sort()
  end

  defp extract_examples_from_file(file_path) do
    content = File.read!(file_path)
    lines = String.split(content, "\n")

    parse_lines(lines, %{
      current_title: nil,
      in_code_block: false,
      current_html: [],
      examples: []
    })
    |> Map.get(:examples)
    |> Enum.reverse()
  end

  defp parse_lines([], state) do
    # If we're still in a code block at EOF, finalize it
    finalize_current_example(state)
  end

  defp parse_lines([line | rest], state) do
    cond do
      # Check for title line: ### ~Title
      String.starts_with?(line, "### ~") ->
        title = String.trim_leading(line, "### ~")
        parse_lines(rest, %{state | current_title: title})

      # Check for start of HTML code block
      String.trim(line) == "```html" ->
        parse_lines(rest, %{state | in_code_block: true, current_html: []})

      # Check for end of code block
      state.in_code_block and String.trim(line) == "```" ->
        new_state = finalize_current_example(state)
        parse_lines(rest, new_state)

      # Collect HTML lines when inside code block
      state.in_code_block ->
        parse_lines(rest, %{state | current_html: [line | state.current_html]})

      # Skip other lines
      true ->
        parse_lines(rest, state)
    end
  end

  defp finalize_current_example(%{current_title: nil} = state) do
    # No title yet, nothing to finalize
    state
  end

  defp finalize_current_example(%{current_html: []} = state) do
    # No HTML collected, nothing to finalize
    state
  end

  defp finalize_current_example(state) do
    html =
      state.current_html
      |> Enum.reverse()
      |> Enum.join("\n")

    example = {state.current_title, html}

    %{
      state
      | examples: [example | state.examples],
        in_code_block: false,
        current_html: []
    }
  end
end
