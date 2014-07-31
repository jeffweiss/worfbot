defmodule Worfbot.DefaultHandler do
  use GenServer

  @moduledoc """
    This is an example event handler that you can attach to the client using
    `add_handler` or `add_handler_async`. To remove, call `remove_handler` or
    `remove_handler_async` with the pid of the handler process.
  """

  defmacro __using__(_opts) do
    quote location: :keep do
      def start! do
        start_link([])
      end

      def start_link(state) do
        GenServer.start_link(__MODULE__, state)
      end

      def init(state) do
        {:ok, state}
      end

      @doc """
      Handle messages from the client

      Examples:

              def handle_info({:connected, server, port}, state) do
                      IO.puts "Connected to \#{server}:\#{port}"
              end
              def handle_info(:logged_in, state) do
                      IO.puts "Logged in!"
              end
              def handle_info(%IrcMessage{:nick => from, :cmd => "PRIVMSG", :args => ["mynick", msg]}, state) do
                      IO.puts "Received a private message from \#{from}: \#{msg}"
              end
              def handle_info(%IrcMessage{:nick => from, :cmd => "PRIVMSG", :args => [to, msg]}, state) do
                      IO.puts "Received a message in \#{to} from \#{from}: \#{msg}"
              end

      """
      def handle_info({:connected, server, port}, state) do
        #debug "Connected to #{server}:#{port}"
        {:noreply, state}
      end
      def handle_info(:logged_in, state) do
        #debug "Logged in to server"
        {:noreply, state}
      end
      def handle_info(:disconnected, state) do
        #debug "Disconnected from server"
        {:noreply, state}
      end
      def handle_info({:joined, channel}, state) do
        #debug "Joined #{channel}"
        {:noreply, state}
      end
      def handle_info({:joined, channel, user}, state) do
        #debug "#{user} joined #{channel}"
        {:noreply, state}
      end
      def handle_info({:topic_changed, channel, topic}, state) do
        #debug "#{channel} topic changed to #{topic}"
        {:noreply, state}
      end
      def handle_info({:nick_changed, nick}, state) do
        #debug "We changed our nick to #{nick}"
        {:noreply, state}
      end
      def handle_info({:nick_changed, old_nick, new_nick}, state) do
        #debug "#{old_nick} changed their nick to #{new_nick}"
        {:noreply, state}
      end
      def handle_info({:parted, channel}, state) do
        #debug "We left #{channel}"
        {:noreply, state}
      end
      def handle_info({:parted, channel, nick}, state) do
        #debug "#{nick} left #{channel}"
        {:noreply, state}
      end
      def handle_info({:invited, by, channel}, state) do
        #debug "#{by} invited us to #{channel}"
        {:noreply, state}
      end
      def handle_info({:kicked, by, channel}, state) do
        #debug "We were kicked from #{channel} by #{by}"
        {:noreply, state}
      end
      def handle_info({:kicked, nick, by, channel}, state) do
        #debug "#{nick} was kicked from #{channel} by #{by}"
        {:noreply, state}
      end
      def handle_info({:received, message, from}, state) do
        #debug "#{from} sent us a private message: #{message}"
        {:noreply, state}
      end
      def handle_info({:received, message, from, channel}, state) do
        #debug "#{from} sent a message to #{channel}: #{message}"
        {:noreply, state}
      end
      def handle_info({:mentioned, message, from, channel}, state) do
        #debug "#{from} mentioned us in #{channel}: #{message}"
        {:noreply, state}
      end
      # This is an example of how you can manually catch commands if ExIrc.Client doesn't send a specific message for it
      def handle_info(%IrcMessage{:nick => from, :cmd => "PRIVMSG", :args => ["testnick", msg]}, state) do
        #debug "Received a private message from #{from}: #{msg}"
        {:noreply, state}
      end
      def handle_info(%IrcMessage{:nick => from, :cmd => "PRIVMSG", :args => [to, msg]}, state) do
        #debug "Received a message in #{to} from #{from}: #{msg}"
        {:noreply, state}
      end
      # Catch-all for messages you don't care about
      def handle_info(msg, state) do
        #debug "Received IrcMessage:" <> inspect(msg)
        {:noreply, state}
      end

      defp debug(msg) do
        IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
      end

      defoverridable [init: 1]
    end
  end

end
