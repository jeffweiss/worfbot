defmodule Worfbot.QuoteHandler do
  require Logger

  @vsn "0"

  # def code_change("0", {name, quotes}, _extra) do
  #   Logger.info "upgrading #{name}"
  #   {:ok, {name, quotes |> Enum.map( &String.upcase/1 ) }}
  # end

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
    Logger.debug "starting QuoteHandler for #{name}"
    Worfbot.Worker.register_handler self
    become_leader(self, name)
    load_quotes(self)
    {:ok, {name, []}}
  end

  def handle_cast(:load_quotes, {name, _oldquotes}) do
    :random.seed(:erlang.now)
    quotes = File.stream!("#{String.downcase name}_quotes.txt")
              |> Stream.map(&String.strip/1)
              # |> Stream.map(&String.upcase/1)
              |> Enum.shuffle
    {:noreply, {name, quotes}}
  end

  def handle_call(:next_quote, _from, state = {_name, [next | rest]}) do
    {:reply, next, state}
  end

  def handle_info({:received, message, from, channel}, state) do
    respond_if_needed({message, channel}, state)
  end

  def handle_info({:received, message, from}, state) do
    respond_if_needed({message, from}, state)
  end

  defp respond_if_needed({message, channel}, state = {name, _}) do
    cond do
      Regex.match?(~r/^crash #{name}$/iu, message) ->
        raise "Ermegerd"
      Regex.match?(~r/#{name}/iu, message) ->
        send_quote({message, channel}, state)
      true ->
        {:noreply, state}
    end
  end

  defp send_quote({_, channel}, {name, [next|rest]}) do
    Worfbot.Worker.send_message channel, name <> ": " <> next
    {:noreply, {name, rest ++ [next]}}
  end

  def handle_info({:mentioned, message, from, channel}, state) do
    debug "#{from} mentioned us in #{channel}: #{message}"
    send_quote({message, channel}, state)
  end

  use Worfbot.DefaultHandler
end
