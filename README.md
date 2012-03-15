# Boomer Sooner

Boomer Sooner is the distributed job processing engine and web-based management app built on Node.js and Hook.io, brought to you from the <a href="http://en.wikipedia.org/wiki/Oklahoma">Sooner State</a>.

Workflows are written in CoffeeScript via the web interface.

## Distributed

Thanks to [Hook.io](https://github.com/hookio/hook.io), "workers" reside on any number of machines, and need only connect to one another via a TCP port you choose.

## Long-Lived

TODO

## Worker

To start up the primary worker, run:

    coffee worker

You can have multiple workers, each responsible for handling different jobs. Designate one worker as the "main" worker, and connect all others to it via the `-c` (connect) switch:

To start up another worker, run:

    coffee worker -c -h IP_OF_MAIN_WORKER -n vip-worker

Where `IP_OF_MAIN_WORKER` should be the first's IP address.

You can name your additional worker in order to target it with different jobs.

## Web UI

To start up the web server, run:

    coffee web -h IP_OF_WORKER

## CLI

    coffee repl -h IP_OF_WORKER

## Workflow API

Each job runs in a separate Node.js context, which has the effect of sandboxing the running code from the parent worker process.

This technique is not full proof, as their are still ways you can crash the parent process, but it helps.

As such, your job only has access to the objects provided it by the sandbox, namely:

### db.connect

*Arguments:*
* connectionName
* callback

*Example:*
```coffeescript
db.connect 'foo', (conn) ->
  # use conn here
```

The `connectionName` is a named connection provided in `config.json` under `dbConnections`. Following is an example connection called "foo":
```json
{
  "dbConnections": {
    "foo": "postgres://postgres@localhost/foo"
  }
}
```

### conn.query

*Arguments:*
* sql
* callback

*Example:*
```coffeescript
db.connect 'foo', (conn) ->
  conn.query 'select now() as when', (rows) ->
    # use rows here
```

### shell.spawn

*Arguments:*
* commandName
* args (array)

Returns a [ChildProcess](http://nodejs.org/api/child_process.html).

The `commandName` is a named shell command provided in `config.json` under `shellCommands`. Following is an example named shell command for "ls":
```json
{
  "shellCommands": {
    "listDir": "ls"
  }
}
```

### shell.run

*Arguments:*
* commandName
* args (array)
* callback

This is a higher level function that executes spawn, then waits for the process to finish. `stdout` and `stderr` are both captured to a single string, then passed via the `callback` function.

*Example:*
```coffeescript
db.run 'listDir', ['/tmp'], (code, output) ->
  # code = return code of the completed process
  # output = stdout+stderr
```

### ftp.connect

*Arguments:*
* connectionName
* callback

TODO
