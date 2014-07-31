defmodule Worfbot.Worker do
  use GenServer

  defmodule State do
    defstruct [
              host: "chat.freenode.net",
              port: 6667,
              pass: "klingon",
              nick: "enterprisebot",
              user: "enterprisebot",
              name: "Enterprise:TNG Bot",
              client: nil,
              handlers: []
              ]
  end

  def client do
    GenServer.call __MODULE__, :client
  end

  def register_handler(handler) do
    GenServer.cast __MODULE__, {:register_handler, handler}
  end

  def join_channels(channels) do
    GenServer.cast __MODULE__, {:join_channels, channels}
  end

  def send_message(recipient, msg) do
    GenServer.cast __MODULE__, {:send_message, recipient, msg}
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [%State{}], name: __MODULE__)
  end

  def init([state]) do
    {:ok, client} = ExIrc.start_client!()
    :random.seed(:erlang.now)

    ExIrc.Client.connect! client, state.host, state.port
    ExIrc.Client.logon    client, state.pass, state.nick, state.user, state.name
    # ExIrc.Client.join     client, "#internship"
    # ExIrc.Client.msg      client, :privmsg, "#internship", "Welcome to the 24th century."

    {:ok, %{state | :client => client}}
  end

  def handle_call(:client, _from, state) do
    {:reply, state.client, state}
  end

  def handle_cast({:register_handler, handler}, state) do
    ExIrc.Client.add_handler state.client, handler
    {:noreply, %{state | :handlers => [handler | state.handlers]}}
  end

  def handle_cast({:send_message, channel, msg}, state) do
    ExIrc.Client.msg state.client, :privmsg, channel, msg
    {:noreply, state}
  end

  def handle_cast({:join_channels, channels}, state) do
    channels |> Enum.map(&ExIrc.Client.join state.client, &1)
    {:noreply, state}
  end

  def terminate(_, state) do
    ExIrc.Client.quit state.client, "The young people will see what it is to die - as a Klingon."
    ExIrc.Client.stop! state.client
    :ok
  end
end
