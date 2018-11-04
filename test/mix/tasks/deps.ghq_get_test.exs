Code.require_file("../../test_helper.exs", __DIR__)

defmodule Mix.Tasks.Deps.GhqGetTest do
  use MixTest.Case

  setup %{describe: describe} = _context do
    "Elixir.Mix.Tasks.Deps.GhqGetTest.#{describe}"
    |> String.to_existing_atom()
    |> Mix.Project.push()
  end

  describe "HexApp" do
    defmodule HexApp do
      def project,
        do: [app: :hex_app, version: "0.1.0", deps: [{:ex_doc, "~> 0.19.1", only: :dev}]]
    end

    test "gets github repos by ghq" do
      in_fixture("no_mixfile", fn ->
        Mix.Tasks.Deps.GhqGet.run([])
        message = "* Ghq getting ex_doc (Hex package)"
        assert_received {:mix_shell, :info, [^message]}
      end)
    end
  end

  describe "GithubApp" do
    defmodule GithubApp do
      def project,
        do: [app: :github_app, version: "0.1.0", deps: [{:ex_doc, "0.19.1", git: git_repo()}]]

      def git_repo, do: "https://github.com/elixir-lang/ex_doc"
    end

    test "gets github repos by ghq" do
      in_fixture("no_mixfile", fn ->
        Mix.Tasks.Deps.GhqGet.run([])
        message = "* Ghq getting ex_doc (#{GithubApp.git_repo()})"
        assert_received {:mix_shell, :info, [^message]}
      end)
    end
  end

  describe "GithubErrorApp" do
    defmodule GithubErrorApp do
      def project,
        do: [
          app: :github_error_app,
          version: "0.1.0",
          deps: [{:ex_docc, "0.1.0", git: "https://github.com/elixir-lang/ex_docc"}]
        ]
    end

    test "does not get github repos by ghq" do
      in_fixture("no_mixfile", fn ->
        exception = assert_raise Mix.Error, fn -> Mix.Tasks.Deps.GhqGet.run([]) end
        assert Exception.message(exception) =~ "Command \"ghq get "
      end)
    end
  end

  describe "GitErrorApp" do
    defmodule GitErrorApp do
      def project,
        do: [
          app: :git_error_app,
          version: "0.1.0",
          deps: [{:git_repo, "0.1.0", git: fixture_path("git_repo")}]
        ]
    end

    test "does not get git repos by ghq" do
      in_fixture("no_mixfile", fn ->
        Mix.Tasks.Deps.GhqGet.run([])
        message = "Command \"ghq get "
        refute_received {:mix_shell, :info, [^message]}
      end)
    end
  end
end
