Mix.start()
Mix.shell(Mix.Shell.Process)
Application.put_env(:mix, :colors, enabled: false)

exclude = if match?({:win32, _}, :os.type()), do: [unix: true], else: [windows: true]
ExUnit.start(trace: "--trace" in System.argv(), exclude: exclude)

unless {1, 7, 4} <= Mix.SCM.Git.git_version() do
  IO.puts(:stderr, "Skipping tests with git sparse checkouts...")
  ExUnit.configure(exclude: :git_sparse)
end

#
# Clear proxy variables that may affect tests
#
System.delete_env("http_proxy")
System.delete_env("https_proxy")
System.delete_env("HTTP_PROXY")
System.delete_env("HTTPS_PROXY")

defmodule MixTest.Case do
  use ExUnit.CaseTemplate

  defmodule Sample do
    def project do
      [app: :sample, version: "0.1.0", aliases: [sample: "compile"]]
    end
  end

  using do
    quote do
      import MixTest.Case
    end
  end

  setup config do
    if apps = config[:apps] do
      Logger.remove_backend(:console)
    end

    on_exit(fn ->
      Application.start(:logger)
      Mix.env(:dev)
      Mix.Task.clear()
      Mix.Shell.Process.flush()
      Mix.ProjectStack.clear_cache()
      Mix.ProjectStack.clear_stack()
      delete_tmp_paths()

      if apps do
        for app <- apps do
          Application.stop(app)
          Application.unload(app)
        end

        Logger.add_backend(:console, flush: true)
      end
    end)

    :ok
  end

  def fixture_path do
    Path.expand("fixtures", __DIR__)
  end

  def fixture_path(extension) do
    Path.join(fixture_path(), extension |> to_string() |> String.replace(":", ""))
  end

  def tmp_path do
    Path.expand("../tmp", __DIR__)
  end

  def tmp_path(extension) do
    Path.join(tmp_path(), extension |> to_string() |> String.replace(":", ""))
  end

  def purge(modules) do
    Enum.each(modules, fn m ->
      :code.purge(m)
      :code.delete(m)
    end)
  end

  def in_tmp(which, function) do
    path = tmp_path(which)
    File.rm_rf!(path)
    File.mkdir_p!(path)
    File.cd!(path, function)
  end

  defmacro in_fixture(which, block) do
    module = inspect(__CALLER__.module)
    function = Atom.to_string(elem(__CALLER__.function, 0))
    tmp = Path.join(module, function)

    quote do
      unquote(__MODULE__).in_fixture(unquote(which), unquote(tmp), unquote(block))
    end
  end

  def in_fixture(which, tmp, function) do
    src = fixture_path(which)
    dest = tmp_path(String.replace(tmp, ":", "_"))
    flag = String.to_charlist(tmp_path())

    File.rm_rf!(dest)
    File.mkdir_p!(dest)
    File.cp_r!(src, dest)

    get_path = :code.get_path()
    previous = :code.all_loaded()

    try do
      File.cd!(dest, function)
    after
      :code.set_path(get_path)

      for {mod, file} <- :code.all_loaded() -- previous,
          file == [] or (is_list(file) and :lists.prefix(flag, file)) do
        purge([mod])
      end
    end
  end

  def ensure_touched(file) do
    ensure_touched(file, File.stat!(file).mtime)
  end

  def ensure_touched(file, current) do
    File.touch!(file)

    unless File.stat!(file).mtime > current do
      ensure_touched(file, current)
    end
  end

  def os_newline do
    case :os.type() do
      {:win32, _} -> "\r\n"
      _ -> "\n"
    end
  end

  def mix(args, envs \\ []) when is_list(args) do
    args = ["-r", mix_executable(), "--" | args]
    System.cmd(elixir_executable(), args, stderr_to_stdout: true, env: envs) |> elem(0)
  end

  def mix_port(args, envs \\ []) when is_list(args) do
    Port.open({:spawn_executable, elixir_executable()}, [
      {:args, ["-r", mix_executable(), "--" | args]},
      {:env, envs},
      :binary,
      :use_stdio,
      :stderr_to_stdout
    ])
  end

  defp mix_executable do
    Path.expand("../../../bin/mix", __DIR__)
  end

  defp elixir_executable do
    Path.expand("../../../bin/elixir", __DIR__)
  end

  defp delete_tmp_paths do
    tmp = tmp_path() |> String.to_charlist()
    for path <- :code.get_path(), :string.str(path, tmp) != 0, do: :code.del_path(path)
  end
end
