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

  def become_leader(pid) do
    :global.register_name __MODULE__, pid
  end

  def find_leader do
    :global.whereis_name __MODULE__
  end

  def client do
    GenServer.call find_leader, :client
  end

  def register_handler(handler) do
    GenServer.cast find_leader, {:register_handler, handler}
  end

  def join_channels(channels) do
    GenServer.cast find_leader, {:join_channels, channels}
  end

  def send_message(recipient, msg) do
    GenServer.cast find_leader, {:send_message, recipient, msg}
  end

  def start_link(nick) do
    GenServer.start_link(__MODULE__, [%State{:nick => nick}], name: __MODULE__)
  end

  def init([state]) do
    become_leader(self)
    {:ok, client} = ExIrc.start_client!()

    ExIrc.Client.connect! client, state.host, state.port
    ExIrc.Client.logon    client, state.pass, state.nick, state.user, state.name

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
