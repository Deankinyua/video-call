defmodule VideoCall.MixProject do
  use Mix.Project

  def project do
    [
      app: :video_call,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: ne3ko_deps() ++ phoenix_deps(),
      dialyzer: [
        # Put the project-level PLT in the priv/ directory (instead of the default _build/ location)
        plt_add_apps: [:ex_unit, :mix],
        plt_file: {:no_warn, "priv/plts/project.plt"}
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        ci: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ],

      # Docs
      name: "Video Call",
      source_url: "https://github.com/Deankinyua/video-call",
      # homepage_url: "http://YOUR_PROJECT_HOMEPAGE",
      docs: &docs/0
    ]
  end

  defp docs do
    [
      # The main page in the docs
      main: "Video Call",
      # logo: "priv/static/images/invoice_logo.svg",
      extras: ["README.md"]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {VideoCall.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.

  defp ne3ko_deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: :test, runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:mix_audit, "~> 2.1", only: :test, runtime: false}
    ]
  end

  defp phoenix_deps do
    [
      {:phoenix, "~> 1.7.18"},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind invoice_generator", "esbuild invoice_generator"],
      "assets.deploy": [
        "tailwind invoice_generator --minify",
        "esbuild invoice_generator --minify",
        "phx.digest"
      ],
      ci: [
        "deps.unlock --check-unused",
        "deps.audit",
        "hex.audit",
        "format --check-formatted",
        "cmd npx prettier -c .",
        "credo --strict",
        "dialyzer",
        "test --cover --warnings-as-errors"
      ],
      prettier: ["cmd npx prettier -w ."]
    ]
  end
end
