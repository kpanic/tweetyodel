defmodule Tweetyodel.Worker do
  use GenServer

  def start_link(name) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(name))
  end

  defp via_tuple(name) do
    {:via, :gproc, {:n, :l, {:tweet_room, name}}}
  end

  def whereis(room_name) do
    :gproc.whereis_name({:n, :l, {:tweet_room, room_name}})
  end

  def init(_)  do
    {:ok, %{}}
  end

  def search(namespace, topic) do
    GenServer.call(via_tuple(namespace), %{search: topic})
  end

  def stream(namespace, topic) do
    GenServer.cast(via_tuple(namespace), %{stream: topic})
  end

  def entries(namespace) do
    GenServer.call(via_tuple(namespace), :entries)
  end

  def handle_call(:entries, _from, state) do
    {:reply, Map.get(state, :tweets, []), state}
  end

  def handle_call(%{search: topic}, _from, state) do
    tweets = ExTwitter.search(topic, [count: 10])
    {:reply, tweets, Map.put(state, :tweets, tweets)}
  end

  defp configure_extwitter do
    ExTwitter.configure(:process, [
          consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
          consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
          access_token: System.get_env("TWITTER_ACCESS_TOKEN"),
          access_token_secret: System.get_env("TWITTER_ACCESS_SECRET")
        ]
    )
  end

  def handle_cast(%{stream: topic}, state) do
    task = Task.async(fn ->
      configure_extwitter
      ExTwitter.stream_filter([track: topic], :infinity)
      |> Enum.take(10)
    end)

    {:noreply, Map.put(state, :tweets, Task.await(task))}
  end
end
