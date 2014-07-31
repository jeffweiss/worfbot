defmodule Worfbot do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      worker(Worfbot.Worker, ["blah"]),
      worker(Worfbot.LoginHandler, ["blah"]),
      worker(Worfbot.QuoteHandler, ["Worf"], id: "Worf"),
      worker(Worfbot.QuoteHandler, ["Riker"], id: "Riker"),
      worker(Worfbot.QuoteHandler, ["Data"], id: "Data"),
      worker(Worfbot.QuoteHandler, ["Geordi"], id: "Geordi"),
      worker(Worfbot.QuoteHandler, ["Picard"], id: "Picard")
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Worfbot.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def main(_argv) do
    start("", "")
  end
end
