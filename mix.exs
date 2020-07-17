defmodule Boss.Mixfile do
  use Mix.Project

  def project do
    [
      app: :boss,
      version: "0.9.0-beta2",
      elixir: "~> 1.9",
      name: "Chicago Boss",
      compilers: [:erlang, :app],
      erlc_options: [{:parse_transform, :lager_transform}, {:parse_transform, :cut}, {:parse_transform, :do}, {:parse_transform, :import_as}],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:boss_db, github: "rlanderdahl/boss_db", ref: "666f42c"},
      {:tinymq, github: "ChicagoBoss/tinymq", tag: "v0.9.0"},
      {:erlydtl, github: "erlydtl/erlydtl", ref: "118c176"},
      {:iso8601, github: "danikp/erlang_iso8601", ref: "ae6a052017"},
      {:mimetypes, github: "spawngrid/mimetypes", branch: "master"},
      {:mochiweb, github: "mochi/mochiweb", ref: "53a9607"},
      {:cowboy, github: "ninenines/cowboy", tag: "2.6.1"},
      {:simple_bridge, github: "nitrogen/simple_bridge", ref: "1938ec7"}
    ]
  end
end
