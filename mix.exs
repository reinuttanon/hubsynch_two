defmodule HubsynchTwo.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        hubsynch_two_a: [
          applications: [
            dashboard: :permanent,
            hub_crm: :permanent,
            hub_identity: :permanent,
            hub_ledger: :permanent,
            hub_payments: :permanent
          ]
        ],
        hubsynch_two_b: [
          applications: [
            dashboard: :permanent,
            hub_crm: :permanent,
            hub_identity: :permanent,
            hub_ledger: :permanent,
            hub_payments: :permanent
          ]
        ],
        hubsynch_two_c: [
          applications: [
            dashboard: :permanent,
            hub_crm: :permanent,
            hub_identity: :permanent,
            hub_ledger: :permanent,
            hub_payments: :permanent
          ]
        ]
      ]
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    []
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: [
        "deps.get",
        "ecto.setup",
        "cmd npm install --prefix assets"
      ],
      "ecto.setup": [
        "ecto.create",
        "ecto.migrate",
        "run apps/hub_identity/priv/repo/seeds.exs",
        "run apps/hub_ledger/priv/repo/seeds.exs"
      ],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
