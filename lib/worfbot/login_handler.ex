defmodule Worfbot.LoginHandler do

  defp channels do
    ["#internship"]
  end

  def init(state) do
    Worfbot.Worker.register_handler self
    {:ok, state}
  end

  def handle_info(:logged_in, state) do
    debug "Logged in to server"
    Worfbot.Worker.join_channels channels
    {:noreply, state}
  end
  use Worfbot.DefaultHandler
end
