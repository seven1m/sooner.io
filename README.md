# Sooner.io

Sooner.io is the distributed job processing engine and web-based management app built on [Node.js](http://nodejs.org) and [Hook.io](http://hook.io), brought to you from the [Sooner State](http://en.wikipedia.org/wiki/Oklahoma).

Jobs are written in CoffeeScript and run on a scheduled or on-demand basis via a distributed network of "workers."

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

## REPL (Read-Eval-Print-Loop)

You can peek inside the Hook.io cloud and receive and emit messages via the REPL:

    coffee repl -h IP_OF_WORKER

## Job API

Each job runs in a separate Node.js process with limited context, which has the effect of sandboxing the running code from the parent worker process.

The idea is to make it difficult for someone to do naughty things to your worker process, the host machine, and your network, but **I explicitly disclaim the secureness of this system -- In fact, I recommend you NOT make this system available via the public web, and that you restrict access with .htaccess or some other technique (authenticationn/authorization is not yet present).**

The following functions are available to your running code:

### done

Call `done()` at the end of every job so the db connections can be cleaned up, otherwise your job may be marked as failed.

### queue

*Arguments:*
* name

Returns the [Mongoose](http://mongoosejs.com/) object for the named queue collection.

See the [Querying](http://mongoosejs.com/docs/query.html) and [Updating](http://mongoosejs.com/docs/updating-documents.html) docs for help.

Each entry in the queue has the following fields defined:

* `_id`
* `status`
* `data`
* `createdAt`

You should only set the `status` and `data` fields yourself.

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

This is a light wrapper around [node-ftp](https://github.com/mscdex/node-ftp).

## License

Copyright (c) 2011, [Tim Morgan](http://timmorgan.org)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
