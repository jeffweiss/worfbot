defmodule Worfbot.Worker do
  use GenServer

  defmodule State do
    defstruct [
              host: "chat.freenode.net",
              port: 6667,
              pass: "klingon",
              nick: "lt_worfbot",
              user: "worfbot",
              name: "Lt. Worf Bot",
              client: nil,
              handlers: []
              ]
  end

  defp channels do
    ["#internship"]
  end

  def client do
    GenServer.call __MODULE__, :client
  end

  def send_next_quote(recipient) do
    GenServer.cast __MODULE__, {:send_next_quote, recipient}
  end

  def join_channels do
    GenServer.cast __MODULE__, :join_channels
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [%State{}], name: __MODULE__)
  end

  def init([state]) do
    IO.puts inspect state
    {:ok, client} = ExIrc.start_client!()
    {:ok, handler} = Worfbot.Handler.start_link(nil)
    :random.seed(:erlang.now)
    quotes = File.stream!("quotes.txt") |> Stream.map(&String.strip/1) |> Enum.shuffle

    ExIrc.Client.add_handler_async client, handler

    ExIrc.Client.connect! client, state.host, state.port
    ExIrc.Client.logon    client, state.pass, state.nick, state.user, state.name
    ExIrc.Client.join     client, "#internship"
    ExIrc.Client.msg      client, :privmsg, "#internship", "Welcome to the 24th century."

    {:ok, {%{state | :client => client, :handlers => [handler]}, quotes}}
  end

  def handle_call(:client, _from, full = {state, _}) do
    {:reply, state.client, full}
  end

  def handle_cast({:send_next_quote, channel}, {state, _quotes = [next|rest]}) do
    ExIrc.Client.msg state.client, :privmsg, channel, next
    {:noreply, {state, rest ++ [next]}}
  end

  def handle_cast(:join_channels, full_state = {state, _quotes}) do
    channels |> Enum.map(&ExIrc.Client.join state.client, &1)
    {:noreply, full_state}
  end

  def terminate(_, {state, _}) do
    ExIrc.Client.quit state.client, "The young people will see what it is to die - as a Klingon."
    ExIrc.Client.stop! state.client
    :ok
  end
end
