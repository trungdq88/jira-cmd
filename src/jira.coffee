pkg = require '../package.json'

program = require 'commander'
commands = require './commands'

class Jira

  constructor: (@program = program) ->
    @initialize()

  initialize: ->
    @program.version "v#{pkg.version}"
    @loadCommands()

  loadCommands: =>
    for item of commands
      new commands[item] @program

  run: =>
    @program.parse process.argv

    unless program.args.length
      @program.help()

module.exports = Jira
