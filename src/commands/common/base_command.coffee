class BaseCommand

  cli:
    command: null
    description: null
    options: {}
    help: null

  constructor: (@program) ->
    @initialize()

  initialize: =>
    @setCommand()
    @setOptions()
    @setAction()
    @setHelp()

  setCommand: =>
    @program = @program
      .command @cli.command
      .description @cli.description

  setOptions: =>
    items = @cli.options

    for i of items
      @program.option items[i].option, items[i].description, items[i].type

  setAction: =>
    @program.action @action

  setHelp: =>
    if @cli.help
      @program.on '--help', =>
        console.log @cli.help

  action: ->
    console.log 'Override me!'

module.exports = BaseCommand
