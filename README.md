# Boomer Sooner

Boomer Sooner is the distributed workflow engine and web-based management app built on Node.js and Hook.io, brought to you from the <a href="http://en.wikipedia.org/wiki/Oklahoma">Sooner State</a>.

Workflows are written in CoffeeScript via the web interface.

## Distributed

Thanks to [Hook.io](https://github.com/hookio/hook.io), "workers" and "listeners" can reside on any number of machines, and need only connected to one another via a TCP port you choose.

## Fault Tolerant

Depending on how your workflow is written, it can be semi-tolerant of failures in the worker process.

First, whenever a workflow registers a hook with Hook.io, the callback is persisted to the database. This allows Boomer Sooner to re-register the same event(s) whenever the worker server is restarted.

Second, since your workflow must call `@done()` whenever it is finished, incomplete workflows can be identified and restarted when needed.

And third, you are encouraged to save relevant data using `@vars`, which persists the data to the database and allows your event callbacks access to the data, even if the worker server is restarted.

## Web UI

To start up the web server, run:

    coffee web

## CLI

TBW

## Worker

TBW

## Listener

TBW
