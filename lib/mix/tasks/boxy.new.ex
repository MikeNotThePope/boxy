defmodule Mix.Tasks.Boxy.New do
  @moduledoc """
  Creates a new Phoenix project with Boxy's opinionated defaults.

  Boxy enforces the following opinions:
    * LiveView is always enabled
    * PostgreSQL is always the database
    * Standard Phoenix project structure

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

    Mix.Tasks.Phx.New.run(opinionated_args)
  end
end
