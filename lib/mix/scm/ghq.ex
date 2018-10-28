defmodule Mix.SCM.Ghq do
  @moduledoc false

  def fetchable? do
    true
  end

  def get(scm, opts) do
    assert_ghq!()
    Mix.shell().print_app()

    repo = get_github_repo(scm, opts)
    ghq!(["get", repo])
  end

  #
  # Helpers
  #
  defp ghq!(args, into \\ default_into()) do
    case System.cmd("ghq", args, into: into, stderr_to_stdout: true) do
      {response, 0} -> response
      {_, _} -> Mix.raise("Command \"ghq #{Enum.join(args, " ")}\" failed")
    end
  end

  defp assert_ghq! do
    case Mix.State.fetch(:ghq_available) do
      {:ok, true} ->
        :ok

      :error ->
        if System.find_executable("ghq") do
          Mix.State.put(:ghq_available, true)
        else
          Mix.raise(
            "Error fetching/updating Ghq repository: the \"ghq\" " <>
              "executable is not available in your PATH. Please install " <>
              "Ghq on this machine."
          )
        end
    end
  end

  defp default_into() do
    case Mix.shell() do
      Mix.Shell.IO -> IO.stream(:stdio, :line)
      _ -> ""
    end
  end

  defp get_github_repo(Hex.SCM, opts),
    do: get_github_link(opts[:repo], opts[:hex]) |> parse_github_repo

  defp get_github_repo(Mix.SCM.Git, opts), do: parse_github_repo(opts[:git])

  defp get_github_repo(_, _), do: ""

  defp get_github_link(repo, package_name) do
    case Hex.API.Package.get(repo, package_name) do
      {:ok, res} ->
        elem(res, 1)["meta"]["links"]["GitHub"]

      {:error, _res} ->
        Mix.shell().info("Failed to retrieve package information: #{package_name}")
        nil
    end
  end

  defp parse_github_repo(nil), do: nil

  defp parse_github_repo(url) do
    match_list =
      cond do
        Regex.match?(~r/^https:/, url) ->
          Regex.named_captures(~r/^https:\/\/github.com\/(?<gh>.*)$/, url)

        Regex.match?(~r/^git:/, url) ->
          Regex.named_captures(~r/^git:\/\/github.com\/(?<gh>.*).git$/, url)

        true ->
          %{"gh" => ""}
      end

    match_list["gh"]
  end
end
