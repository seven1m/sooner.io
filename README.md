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
    mkdir scripts.git
    cd scripts.git
    git init --bare
    rm -rf hooks
    ln -sr ../lib/git-hooks hooks
    cd ..
    git clone scripts.git scripts-working-copy

The `scripts.git` directory is a bare repo to which you should push (see further explanation lower in this file).

## Worker

To start up a worker, run:

    coffee bin/worker

You can have multiple workers, each responsible for handling different jobs. They can each run on the same or separate machines -- doesn't matter!

You will probably want to give each worker a different name, which you can do with the `-n` switch:

    coffee bin/worker -n vip-worker

## Web UI

To start up the web server, run:

    coffee bin/web

## Job Scripts

A job is simply a script on the file system plus some metadata including schedule (cron), hooks, target worker, etc, which can be updated via the web UI.

A script can be written in any language, e.g. bash, ruby, python, etc., though JavaScript/CoffeeScript is recommended in order to utilize the existing Mongoose Queue model.

Here's perhaps the simplest possible script:

```bash
#!/usr/bin/env bash

echo 'done!'
```

### Updating Jobs

When you setup Sooner.io under the Configuration section above, you set up a bare git repository living inside the Sooner.io directory called `scripts.git`, along with a cloned copy in `scripts-working-copy`.

This is designed so that you can push directly to the scripts repo via ssh from your local workstation. Doing so will trigger the post-update git hook and update the working copy.

First, on your local machine, clone the scripts repo:

    git clone username@server:/var/www/apps/sooner.io/scripts.git sooner-scripts

You will initially see an empty directory. Create your script there, mark it as executable (required), and commit it. Then push:

    vim myScript.coffee
    chmod +x myScript.coffee
    git add myScript.coffee
    git commit -m "Add myScript"
    git push origin master

The output you see next should indicate the creation of a new job. Next you should visit the web interface and enable the job (all new jobs are disabled by default) and configure the other settings as desired.

An alternative means of updating scripts is to work directly on the server (not optimal, but handy when testing small changes):

    cd /var/www/apps/sooner.io/scripts-working-copy
    vim myScript.coffee
    coffee ../bin/deployer.coffee update

Just be sure to and and commit your change once finished and `git push`.

### API

There is something of an API that scripts can utilize to tell Sooner.io to do specific things. Namely, there are two methods called `progress` and `emit` (documented below).

Making calls to those methods is done via RPC over one of two channels:

1. via [dnode](https://github.com/substack/dnode) which has library support for Node.js, Perl, Ruby, PHP, and Java.
2. via stderr output (low-tech, but should work with just about any language)

#### API calls via dnode

Here is an example of using dnode from within CoffeeScript:

```coffeescript
#!/usr/bin/env coffee

dnode = require 'dnode'
dnode.connect process.argv[2], (remote, conn) ->
  console.log 'half way'
  remote.progress 50
  done = ->
    console.log 'done!'
    conn.end()
  setTimeout done, 2000
```

A few things to note:

* The first argument passed to your script is the unix socket that dnode can use to communicate with the parent process. This socket is automatically cleaned up once your script is finished executing.
* Speaking of "finished", you will need to call `conn.end()` once you are finished working in order to close the dnode socket connection.

#### API calls via stderr

A lower-tech way of communicating is to echo to `stderr`, which can be done in bash with `echo "foo" 1>&2`. Since stderr may additionally be used for other messages, you must prefix your RPC call with `>>> sooner.` so that Sooner.io knows what you mean. This works from bash like so:

```bash
#!/usr/bin/env bash

echo 'half way'
echo '>>> sooner.progress(50)' 1>&2
echo '>>> sooner.emit("foo-event")' 1>&2
sleep 2

echo 'done!'
```

#### emit

*Arguments:*

* event
* data

Emits an event that other jobs can watch, consequently allowing one job to trigger another job. Data passed as the second argument is available to any triggered jobs as the `data` variable.

#### progress

*Arguments:*

* current
* max (optional, defaults to 100)

If you wish to track incremental progress of your job, you may call, e.g. `progress(5, 10)` (this will show a progress bar at half-way). The first argument is the current number of units of work complete, while the second is the total number of units of work. The second argument is optional and can be used to change the maximum on the fly.

### Queue Access

The Queue model (available in `models/queue.coffee`) is something you can use to store and retrieve work to be done. Queues are browsable, filterable, and sortable via the web interface, so they are great for keeping track of work done and/or to-be-done.

Here's how you would access a Queue from a CoffeeScript script:

```coffeescript
queue = require __dirname + '/../models/queue'
queue.connect()

q = queue('profiles')

q.where('status', 'pending').run (err, profiles) ->
  # do work here
  queue.disconnect() # need this to close the MongoDB connection
```

Essentially, the `queue` function returns a [Mongoose](http://mongoosejs.com/) model attached to a similarly-named MongoDB collection (prepended with `queue_`) to which you are free to query, insert, update, and delete.

See the [Querying](http://mongoosejs.com/docs/query.html) and [Updating](http://mongoosejs.com/docs/updating-documents.html) Mongoose docs for help.

Each entry in the queue has the following fields defined:

* `_id`
* `status`
* `data`
* `createdAt`
* `updatedAt`

You should only set the `status` and `data` fields yourself. Store an object in the `data` attribute with as much information as you need to track your work. If you manage to keep the data object flat (only a single-layer JS object), all the attributes will be easily visible via the web interface in table form (though it is indeed possible to store nested objects as well)

## License

Copyright (c) 2012, [Tim Morgan](http://timmorgan.org)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
