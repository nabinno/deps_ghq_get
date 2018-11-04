defmodule Mix.Dep.GhqGetter do
  @moduledoc """
  Module responsible for running `ghq get` dependencies from their sources.
  """

  @doc """
  Runs `ghq get` all dependencies.
  """
  def all(async) when async do
    Mix.Dep.Converger.converge(nil, nil, %{}, &{&1, &2, &3})
    |> elem(0)
    |> Task.async_stream(&do_ghq_get/1)
    |> Stream.run()
  end

  def all do
    Mix.Dep.Converger.converge(nil, nil, %{}, &{&1, &2, &3})
    |> elem(0)
    |> Enum.each(&do_ghq_get/1)
  end

  def do_ghq_get(%Mix.Dep{scm: scm, opts: opts} = dep) do
    cond do
      # Dependencies that cannot be run `ghq get` are always compiled afterwards
      not Mix.SCM.Ghq.fetchable?() ->
        nil

      # The dependency is ok or has some other error
      true ->
        Mix.shell().info("* Ghq getting #{format_dep(dep)}")
        Mix.SCM.Ghq.get(scm, opts)
    end
  end

  def format_dep(%Mix.Dep{scm: scm, app: app, opts: opts}) do
    "#{app} (#{scm.format(opts)})"
  end
end
