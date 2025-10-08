defmodule Boxy do
  @moduledoc """
  Documentation for `Boxy`.
  """

  @test_app_dir "tmp"

  @doc """
  Returns the directory where test apps should be created during development.
  """
  def test_app_dir, do: @test_app_dir

  @doc """
  Hello world.

  ## Examples

      iex> Boxy.hello()
      :world

  """
  def hello do
    :world
  end
end
