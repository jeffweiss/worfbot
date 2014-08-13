defmodule Worfbot.Spam do
  def spam(recipient) do
    :erlang.now
    |> :random.seed

    :global.registered_names
    |> Enum.shuffle
    |> List.first
    |> :global.whereis_name
    |> Kernel.send {:mentioned, "wat", "wat", recipient}

    :random.uniform(30000)
    |> :timer.sleep

    spam(recipient)
  end
end
