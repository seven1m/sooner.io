childProcess = require('child_process')
fs = require('fs')
mongoose = require('mongoose')
models = require(__dirname + '/../models')

class Deployer

  jobsDir: __dirname + '/../scripts-working-copy/'
  reportsPath: 'reports/'

  constructor: (opts) ->
    @opts = opts
    @config = JSON.parse(fs.readFileSync(@opts.config))
    @git = @config.gitBinary
    @setupDB()

  update: (callback) =>
    @getJobs =>
      @loadScripts callback

  end: =>
    mongoose.disconnect()

  setupDB: =>
    mongoose.connect @config.db

  getJobs: (callback) =>
    models.job.find deleted: false, (err, jobs) =>
      if err then throw err
      @paths = {}
      @paths[job.path] = job for job in jobs
      callback()

  jobFiles: =>
    fs.readdirSync @jobsDir

  reportFiles: =>
    @reportsPath + p for p in fs.readdirSync @jobsDir + @reportsPath

  loadScripts: (callback) =>
    @found = {}
    @ops = 0
    for file in @jobFiles().concat @reportFiles()
      @ops++
      @found[file] = true
      @updateJob file, (job) =>
        if --@ops == 0
          callback()
    for path, job of @paths
      unless @found[path]
        @ops++
        @deleteJob job, =>
          if --@ops == 0
            callback()

  updateJob: (path, callback) =>
    fullPath = "#{@jobsDir}/#{path}"
    fs.stat fullPath, (err, stats) =>
      if err then throw err
      if @isScript(path, stats)
        if job = @paths[path]
          console.log "updating #{job.name}"
          job.deleted = false
          job.save (err) =>
            if err then throw err
            callback job
        else
          # TODO track renames
          console.log "adding #{path}"
          report = path.match(/^reports\//)?
          job = new models.job
            name: path.split(/\//)[1]
            workerName: 'worker'
            enabled: report # jobs are disabled by default
            path: path
            report: report
          job.save (err) =>
            if err then throw err
            callback job
      else
        callback()

  isScript: (path, stats) =>
    stats.isFile() and not path.match(/^\./) and stats.mode & 64 # executable by user

  deleteJob: (job, callback) =>
    console.log "marking #{job.name} as deleted"
    job.deleted = true
    job.save (err) =>
      if err then throw err
      callback()

module.exports = Deployer
