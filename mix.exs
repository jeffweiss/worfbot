defmodule Worfbot.Mixfile do
  use Mix.Project

  def project do
    [app: :worfbot,
     version: "0.0.1",
     elixir: "~> 0.15.1",
     escript: escript_config,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:exirc, :logger],
     mod: {Worfbot, []}]
  end

  # Dependencies can be hex.pm packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    #[{:exirc, github: "jeffweiss/exirc", ref: "update_for_elixir-0.15.1"}]
    [{:exirc, "~> 0.8.0"}]
  end

  defp escript_config do
    [main_module: Worfbot, emu_args: " --no-halt"]
  end
end
