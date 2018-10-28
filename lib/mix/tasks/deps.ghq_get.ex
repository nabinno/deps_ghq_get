defmodule Mix.Tasks.Deps.GhqGet do
  use Mix.Task

  @shortdoc "Run `ghq get` all out of date dependencies"

  @moduledoc """
  Run `ghq get` all out of date dependencies, i.e. dependencies
  that are not available or have an invalid lock.

  ## Command line options

    * `--no-archives-check` - does not check archives before running `ghq get` deps
  """

  def run(args) do
    unless "--no-archives-check" in args do
      Mix.Task.run("archive.check", args)
    end

    Mix.Project.get!()

    apps = Mix.Dep.GhqGetter.all()

    if apps == [] do
      Mix.shell().info("All dependencies up to date")
    else
      :ok
    end
  end
end
