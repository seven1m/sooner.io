# Boomer Sooner

Boomer Sooner is the distributed workflow engine and web-based management app built on Node.js and Hook.io, brought to you from the <a href="http://en.wikipedia.org/wiki/Oklahoma">Sooner State</a>.

Workflows are written in CoffeeScript via the web interface.

## Distributed
m
Thanks to [Hook.io](https://github.com/hookio/hook.io), "workers" and "listeners" can reside on any number of machines, and need only connected to one another via a TCP port you choose.

## Fault Tolerant

Depending on how your workflow is written, it can be semi-tolerant of failures in the worker process.

1. Whenever a workflow registers a hook with Hook.io, the callback is persisted to the database. This allows Boomer Sooner to re-register the same event(s) whenever the worker server is restarted.
2. Your workflow must call `@done()` whenever it is finished; incomplete workflows are restarted when the worker comes back up.
3. Save data using `@vars`, which persists your data to the database and allows your event callbacks access to the data, even if the worker server is restarted.

## Worker

To start up the worker, run:

    coffee worker -h IP_OF_WORKER

Where `IP_OF_WORKER` should be this host's bind address, which allows other nodes to connect to it.

## Web UI

To start up the web server, run:

    coffee web -h IP_OF_WORKER

## CLI

    coffee worker -c -h IP_OF_WORKER --repl
