# Tweetyodel

**Just another twitter experiment**

![Yodeling!](/pic/yodel.jpg)

## What is Tweetyodel?

It is a `GenServer` that can search or stream the Twitter API.
Think about it like one process per Twitter query/topic, ideal to easily
integrate with *Phoenix* channels or other applications.

**NOTE**: It's a pet project, however if you would like to give it a try, why not!


## Configuration

Export these environment variables (you have to create your twitter app first on https://apps.twitter.com/)

```bash
export TWITTER_CONSUMER_KEY="0123456789"
export TWITTER_CONSUMER_SECRET="0123456789"
export TWITTER_ACCESS_TOKEN="0123456789"
export TWITTER_ACCESS_SECRET="0123456789"
```

You have also the possibility to configure:

```elixir
config :tweetyodel,
  max_keep_tweets: 100,
  purge_interval: 30_000
```

`:max_keep_tweets` is the number of maximum tweets that you want to keep in
your `GenServer` process after the purge operation

`:purge_interval` is the number of milliseconds that you want to wait to purge
the tweets. They will be reset to `:max_keep_tweets` after this interval
periodically.

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

If you want your twitter stream to start to pull tweets instantly:
```elixir
Tweetyodel.Worker.start_stream("ma' namespace", "linux", 0)
```

If you want to search instantly Twitter:

```elixir
Tweetyodel.Worker.search("ma' namespace", "#myelixirstatus")
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

