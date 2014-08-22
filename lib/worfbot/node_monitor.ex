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
        node = Node.self |> to_string
        :os.cmd('osascript -e "set volume 6"')
        :os.cmd('say We are Borg. You will be assimilated. Resistance is futile.')
        spam = fn (itself, recipient) ->
          :Worf_quotes
          |> :global.whereis_name
          |> Kernel.send {:mentioned, "not a real message", node, recipient}

          :random.uniform(15_000)
          |> :timer.sleep
          
          itself.(itself, recipient)
        end
        :timer.sleep(3_000)
        who = case :global.whereis_name(:spammer) do
          :undefined ->
            :global.register_name(:spammer, self)
            Logger.info "[" <> node <> "] Botnet joined. No other spammer. I will do it."
            :me
          pid -> 
            Logger.info "[" <> node <> "] Botnet joined. Someone else is currently spamming."
            :someone_else
        end

        if who == :me do
          :timer.sleep(3_000)
          spam.(spam, "jeffweiss")
        end

          
        '''
        Node.spawn(node, Code, :eval_string, [code_string])
      {:nodedown, node} ->
        Logger.info "NodeMonitor: #{node} left"
        if :global.whereis_name(:spammer) == :undefined do
          case Node.list |> Enum.shuffle |> List.first do
            nil ->
              Logger.info "No more members of botnot. Spamming ceased."
            node ->
              Logger.debug "I have elected: #{node}"
              code_string = '''
              require Logger
              node = Node.self |> to_string
              spam = fn (itself, recipient) ->
                :Worf_quotes
                |> :global.whereis_name
                |> Kernel.send {:mentioned, "not a real message", node, recipient}

                :random.uniform(15_000)
                |> :timer.sleep
                
                itself.(itself, recipient)
              end
              :global.register_name(:spammer, self)
              Logger.info "[" <> node <> "] No other spammer. I will do it."
              :timer.sleep(3_000)
              spam.(spam, "jeffweiss")
              '''
              Node.spawn(node, Code, :eval_string, [code_string])
          end
        end
    end
    monitor
  end
end
