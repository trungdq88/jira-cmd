BaseCommand = require './common/base_command.coffee'

class ListCommand extends BaseCommand

  cli:
    command: 'ls'
    description: 'List issues'
    options:
      project:
        option: '-p, --project <name>'
        description: 'Filter by project'
        type: String
      type:
        option: '-t, --type <name>'
        description: 'Filter by type'
        type: String
    help: null

  action: (options) ->
    if options.project
      console.log options.project
    if options.type
      console.log options.type

module.exports = ListCommand
