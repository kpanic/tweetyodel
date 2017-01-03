defmodule Tweetyodel.Twitter do
  use GenServer

  def start_link(twitter_info) do
    GenServer.start_link(__MODULE__, twitter_info, [])
  end

  def init(twitter_info) do
    Process.send_after(self(), twitter_info, 0)
    {:ok, []}
  end

  def handle_info(%{pid: pid, topic: topic}, state) do
    Tweetyodel.Worker.configure_extwitter()
    for tweet <- ExTwitter.stream_filter([track: topic], :infinity) do
      send pid, {:tweet, tweet}
    end
    {:noreply, state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end
end
