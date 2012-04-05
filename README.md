# Sooner.io

Sooner.io is the distributed job scheduling engine and web-based management app built on [Node.js](http://nodejs.org), brought to you from the [Sooner State](http://en.wikipedia.org/wiki/Oklahoma).

Jobs are written in CoffeeScript and run on a scheduled or on-demand basis via a distributed network of "workers."

Some screenshots can be seen at [sooner.io](http://sooner.io).

I created a short presentation about Sooner.io [here](https://docs.google.com/a/timmorgan.org/presentation/d/1RQyZjI77Xb2jVJCvFwXWHpZEFAhbzgnPzn-WbWlc6Ik/present).

## Installation and Configuration

You'll need at least Node.js 0.6.x and MongoDB.

    git clone git://github.com/seven1m/sooner.io.git
    cd sooner.io
    npm install
    cp config{.example,}.json

## Worker

To start up a worker, run:

    coffee worker

You can have multiple workers, each responsible for handling different jobs. They can each run on the same or separate machines -- doesn't matter!

You will probably want to give each worker a different name, which you can do with the `-n` switch:

    coffee worker -n vip-worker

## Web UI

To start up the web server, run:

    coffee web

<a name="job-api"></a>
## Job API

Each job runs in a separate Node.js process with limited context, which has the effect of sandboxing the running code from the parent worker process.

The idea is to make it difficult for someone to do naughty things to your worker process, the host machine, and your network, but **I explicitly disclaim the secureness of this system -- In fact, I recommend you NOT make this system available via the public web, and that you restrict access with .htaccess or some other technique (authentication/authorization is not yet present).**

The following functions are available to your running code:

### done

Call `done()` at the end of every job so the db connections can be cleaned up, otherwise your job may be marked as failed.

### emit

*Arguments:*

* event
* data

Emits an event that other jobs can watch, consequently allowing one job to trigger another job. Data passed as the second argument is available to any triggered jobs as the `data` variable.

### progress

*Arguments:*

* current
* max (optional, defaults to 100)

If you wish to track incremental progress of your job, you may call, e.g. `progress(5, 10)` (this will show a progress bar at half-way). The first argument is the current number of units of work complete, while the second is the total number of units of work. The second argument is optional and can be used to change the maximum on the fly.

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

Connects to a named database (PostgreSQL only at the moment).

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
* params (optional)
* callback

*Example:*

```coffeescript
db.connect 'foo', (conn) ->
  conn.query 'select * from foo where bar=$1', ['baz'], (rows) ->
    # use rows here
```

### conn.end

*No arguments*

Closes the database connection.

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

`callback` is passed an FTPConnection object with the following methods:

* `list(path, callback)`
* `mkdir(name, callback)`
* `put(inSTream, filename, callback)`
* `get(filename, callback)`
* `rename(oldFilename, newFilename, callback)`
* `end()`

Setup FTP server connection details in `config.json`:

```json
{
  "ftpServers": {
    "foo": {
      "host": "ftp.example.com",
      "username": "user",
      "password": "secret"
    }
  }
}
```

### fs.readStream

*Arguments:*

* path

Returns an opened read stream. See the Node.js [documentation](http://nodejs.org/api/fs.html#fs_fs_createreadstream_path_options).

### fs.writeStream

*Arguments:*

* path

Returns an opened write stream. See the Node.js [documentation](http://nodejs.org/api/fs.html#fs_fs_createwritestream_path_options).

### xml.stringToJSON

*Arguments:*

* string
* callback

Converts XML in string into a JSON object and runs `callback(err, json)`.

### xml.fileToJSON

*Arguments:*

* path
* callback

Reads file contents from path and converts XML into a JSON object and runs `callback(err, json)`.

## License

Copyright (c) 2012, [Tim Morgan](http://timmorgan.org)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
