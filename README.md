# DepsGhqGet --- Mix.Tasks.Deps.GhqGet
DepsGhqGet is a mix deps task. It run `ghq get` and then sync/clone with a GitHub repository that depends on your
project. You just type `mix do deps.get, deps.ghq_get`.

## Installations
### By archive.install
```sh
$ mix archive.install https://github.com/nabinno/deps_ghq_get/raw/master/archives/deps_ghq_get-0.1.2.ez
```

### By mix.exs
```elixir
def deps do
  [
    {:deps_ghq_get, "~> 0.1.2", only: :dev}
  ]
end
```

---

## Contributing
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## EPILOGUE
>     A whale!
>     Down it goes, and more, and more
>     Up goes its tail!
>
>     -Buson Yosa
