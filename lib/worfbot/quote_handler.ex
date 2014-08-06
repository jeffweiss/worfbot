defmodule Worfbot.QuoteHandler do

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: :"#{name}_quotes")
  end

  def load_quotes(pid) do
    GenServer.cast(pid, :load_quotes)
  end

  def next_quote(pid) do
    GenServer.call(pid, :next_quote)
  end

  def become_leader(pid, name) do
    :global.register_name :"#{name}_quotes", pid
  end

  def init(name) do
    Worfbot.Worker.register_handler self
    become_leader(self, name)
    load_quotes(self)
    {:ok, {name, []}}
  end

  def handle_cast(:load_quotes, {name, _oldquotes}) do
    :random.seed(:erlang.now)
    quotes = File.stream!("#{String.downcase name}_quotes.txt") |> Stream.map(&String.strip/1) |> Enum.shuffle
    {:noreply, {name, quotes}}
  end

  def handle_call(:next_quote, _from, state = {_name, [next | rest]}) do
    {:reply, next, state}
  end

  def handle_info({:received, message, from, channel}, {name, quotes = [next|rest]}) do
    if Regex.match?(~r/#{name}/iu, message) do
      Worfbot.Worker.send_message channel, name <> ": " <> next
      {:noreply, {name, rest ++ [next]}}
    else
      {:noreply, {name, quotes}}
    end
  end

  def handle_info({:mentioned, message, from, channel}, {name, [next|rest]}) do
    debug "#{from} mentioned us in #{channel}: #{message}"
    Worfbot.Worker.send_message channel, name <> ": " <> next
    {:noreply, {name, rest ++ [next]}}
  end
  use Worfbot.DefaultHandler
end
