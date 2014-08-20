defmodule Worfbot.Spam do
  def spam(recipient) do
    #:erlang.now
    #|> :random.seed

    #:global.registered_names
    #|> Enum.shuffle
    #|> List.first
    :Worf_quotes
    |> :global.whereis_name
    |> Kernel.send {:mentioned, "not a real message", "spammer", recipient}

    :random.uniform(15_000)
    |> :timer.sleep

    spam(recipient)
  end

end
