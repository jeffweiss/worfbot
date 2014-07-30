defmodule Worfbot.QuoteHandler do

  def start_link(name) do
    GenServer.start_link(__MODULE__, name)
  end

  def init(name) do
    :random.seed(:erlang.now)
    quotes = File.stream!("#{String.downcase name}_quotes.txt") |> Stream.map(&String.strip/1) |> Enum.shuffle
    Worfbot.Worker.register_handler self
    {:ok, {name, quotes}}
  end

  def handle_info({:mentioned, message, from, channel}, {name, [next|rest]}) do
    debug "#{from} mentioned us in #{channel}: #{message}"
    Worfbot.Worker.send_message channel, name <> ": " <> next
    {:noreply, {name, rest ++ [next]}}
  end
  use Worfbot.DefaultHandler
end
