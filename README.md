# Tweetyodel

**Just another twitter experiment**

## Configuration

Export these environment variables (you have to create your twitter app first on https://apps.twitter.com/)

```bash
export TWITTER_CONSUMER_KEY="0123456789"
export TWITTER_CONSUMER_SECRET="0123456789"
export TWITTER_ACCESS_TOKEN="0123456789"
export TWITTER_ACCESS_SECRET="0123456789"
```

## How to use

```elixir
Tweetyodel.Worker.Supervisor.start_tweet("ma' namespace")
```

If you want to use the **Twitter Streaming API**, follow these steps:

```elixir
# Bieber has always tweets
Tweetyodel.Worker.start_stream("ma' namespace", "bieber")
# Fetch only the the first 5 tweets and their text
# NOTE that pulling data from twitter starts after 10 seconds
Enum.map(Tweetyodel.Worker.entries("ma' namespace"), fn tweet -> tweet.text end) |> Enum.take(5)
```

If you want to search instantly Twitter:

```elixir
Tweetyodel.Worker.search("ma' namespace", "microsoft")
```

You can also stop the stream (which will stop and kill the streaming process)
However it will keep the tweets searched or streamed
```elixir
Tweetyodel.Worker.stop_stream("ma' namespace")
```

**NOTE** also that a purge cleanup happens every minute which purges the tweets to the last **100**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `tweetyodel` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:tweetyodel, "~> 0.1.0"}]
    end
    ```

  2. Ensure `tweetyodel` is started before your application:

    ```elixir
    def application do
      [applications: [:tweetyodel]]
    end
    ```

