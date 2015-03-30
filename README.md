# jira-cmd

A Jira command line interface inspired by [jilla](https://github.com/godmodelabs/jilla).

[![NPM Version](https://badge.fury.io/js/jira-cmd.svg)](https://npmjs.org/package/jira-cmd)
[![Package downloads](http://img.shields.io/npm/dm/jira-cmd.svg)](https://npmjs.org/package/jira-cmd)

## Installation

Install [node.js](http://nodejs.org/).

Then, in your shell type:

    $ npm install -g jira-cmd

## Usage

##### First use

    $ jira
    Jira URL: https://jira.atlassian.com/
    Username: xxxxxx
    Password: xxxxxx
    Information stored!

This save your credentials (base64 encoded) in your `$HOME/.jira` folder.

##### Help

Usage: jira [options] [command]

  Commands:

    ls [options]           List my issues
    start <issue>          Start working on an issue.
    stop <issue>           Stop working on an issue.
    review <issue> [assignee] Mark issue as being reviewed [by assignee(optional)].
    done <issue>           Mark issue as finnished.
    running                List issues in progress.
    jql <query>            Run JQL query
    search <term>          Find issues.
    assign <issue> [user]  Assign an issue to <user>. Provide only issue# to assign to me
    comment <issue> [text] Comment an issue.
    worklog <issue>        View the worklog of an issue.
    worklogadd <issue> <timeSpent> [comment] Add a new worklog to an issue.
    show [options] <issue> Show info about an issue
    create                 Create an issue or a sub-task
    config [options]       Change configuration

  Options:

    -h, --help     output usage information
    -V, --version  output the version number

Each command have individual usage help (using --help or -h)

## License

[MIT](LICENSE.md)
