defmodule Mix.Tasks.Deps.GhqGet do
  use Mix.Task

  @shortdoc "Run `ghq get` all out of date dependencies"

  @moduledoc """
  Run `ghq get` all out of date dependencies, i.e. dependencies
  that are not available or have an invalid lock.

  ## Command line options

    * `--async` - run `ghq get` deps with using Task.async_stream
  """

  def run(args) do
    {time, _} =
      :timer.tc(fn ->
        Mix.Project.get!()

        cond do
          "--async" in args -> Mix.Dep.GhqGetter.all(true)
          true -> Mix.Dep.GhqGetter.all()
        end
      end)

    Mix.shell().info("== Ghq got in #{inspect(div(time, 100_000) / 10)}s")
  end
end
