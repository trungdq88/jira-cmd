#!/usr/bin/env node

var requirejs = require('requirejs');

requirejs.config({
  baseUrl: __dirname
});

requirejs([
  'commander',
  '../lib/config',
  '../lib/auth',
  '../lib/jira/ls',
  '../lib/jira/describe',
  '../lib/jira/assign',
  '../lib/jira/comment',
  '../lib/jira/create',
  '../lib/jira/sprint',
  '../lib/jira/transitions',
  '../lib/jira/worklog'
], function (program, config, auth, ls, describe, assign, comment, create, sprint, transitions, worklog) {

  program
    .version('v0.5.4');

  program
    .command('ls')
    .description('List my issues')
    .option('-p, --project <name>', 'Filter by project', String)
    .option('-t, --type <name>', 'Filter by type', String)
    .action(function (options) {
      auth.setConfig(function (auth) {
        if (auth) {
          if (options.project) {
            ls.showByProject(options.project, options.type);
          } else {
            ls.showAll(options.type);
          }
        }
      });
    });

  program
    .command('start <issue>')
    .description('Start working on an issue.')
    .action(function (issue) {
      auth.setConfig(function (auth) {
        if (auth) {
          transitions.start(issue);
        }
      });
    });

  program
    .command('move <issue> <transitionName>')
    .description('Move an issue to a transition name.')
    .action(function (issue, transitionName) {
      auth.setConfig(function (auth) {
        if (auth) {
          transitions.move(issue, transitionName);
        }
      });
    });

  program
    .command('stop <issue>')
    .description('Stop working on an issue.')
    .action(function (issue) {
      auth.setConfig(function (auth) {
        if (auth) {
          transitions.stop(issue);
        }
      });
    });

  program
    .command('review <issue> [assignee]')
    .description('Mark issue as being reviewed [by assignee(optional)].')
    .action(function (issue, assignee) {
      auth.setConfig(function (auth) {
        if (auth) {
          transitions.review(issue);
          if(assignee) {
            assign.to(issue, assignee);
          }
        }
      });
    });

  program
    .command('done <issue>')
    .option('-r, --resolution <name>', 'resolution name (e.g. \'Resolved\')', String)
    .option('-t, --timeSpent <time>', 'how much time spent (e.g. \'3h 30m\')', String)
    .description('Mark issue as finished.')
    .action(function (issue, options) {
      auth.setConfig(function (auth) {
        if (auth) {

          if (options.timeSpent) {
            worklog.add(issue, options.timeSpent, "auto worklog", new Date());
          }

          transitions.done(issue, options.resolution);
        }
      });
    });

  program
    .command('running')
    .description('List issues in progress.')
    .action(function () {
      auth.setConfig(function (auth) {
        if (auth) {
          ls.showInProgress();
        }
      });
    });

  program
    .command('jql <query>')
    .description('Run JQL query')
    .action(function (query) {
      auth.setConfig(function (auth) {
        if (auth) {
          ls.jqlSearch(query);
        }
      });
    });

  program
    .command('search <term>')
    .description('Find issues.')
    .action(function (query) {
      auth.setConfig(function (auth) {
        if (auth) {
          ls.search(query);
        }
      });
    });


  program
    .command('assign <issue> [user]')
    .description('Assign an issue to <user>. Provide only issue# to assign to me')
    .action(function (issue, user) {
      auth.setConfig(function (auth) {
        if (auth) {
          if(user) {
            assign.to(issue, user);
          } else {
            assign.me(issue);
          }
        }
      });
    });

  program
    .command('comment <issue> [text]')
    .description('Comment an issue.')
    .action(function (issue, text) {
      auth.setConfig(function (auth) {
        if (auth) {
          if (text) {
            comment.to(issue, text);
          } else {
            comment.show(issue);
          }
        }
      });
    });

  program
    .command('show <issue>')
    .description('Show info about an issue')
    .option('-o, --output <field>', 'Output field content', String)
    .action(function (issue, options) {
      auth.setConfig(function (auth) {
        if (auth) {
          if (options.output) {
            describe.show(issue, options.output);
          } else {
            describe.show(issue);
          }
        }
      });
    });

  program
    .command('open <issue>')
    .description('Open an issue in a browser')
    .action(function (issue, options) {
      auth.setConfig(function (auth) {
        if (auth) {
          describe.open(issue);
        }
      });
    });

  program
    .command('worklog <issue>')
    .description('Show worklog about an issue')
    .action(function (issue) {
      auth.setConfig(function (auth) {
        if (auth) {
          worklog.show(issue);
        }
      });
    });

    program
    .command('worklogadd <issue> <timeSpent> [comment]')
    .description('Log work for an issue')
    .option("-s, --startedAt [value]","Set date of work (default is now)")
    .action(function (issue, timeSpent, comment, p) {
      auth.setConfig(function (auth) {
        if (auth) {
          var o = p.startedAt || new Date().toString(), s = new Date(o);
          worklog.add(issue, timeSpent, comment, s);
        }
      });
    }).on('--help', function () {
      console.log('  Worklog Add Help:');
      console.log();
      console.log('    <issue>: JIRA issue to log work for');
      console.log('    <timeSpent>: how much time spent (e.g. \'3h 30m\')');
      console.log('    <comment> (optional) comment');
      console.log();
    });

  program
    .command('create [project[-issue]]')
    .description('Create an issue or a sub-task')
    .action(function (projIssue) {
      auth.setConfig(function (auth) {
        if (auth) {
          create.newIssue(projIssue);
        }
      });
    });

  program
    .command('new-issue')
    .option("-p, --project [value]", "Project ID")
    .option("-e, --parrentTask [value]", "Parent task ID (number only)")
    .option("-r, --priority [value]", "Priority ID")
    .option("-y, --type [value]", "Issue type ID")
    .option("-t, --title [value]", "Issue title")
    .option("-d, --description [value]", "Issue description")
    .option("-a, --assignee [value]", "Assignee")
    .option("-s, --sprint [value]", "Sprint ID")
    .option("-l, --sprintCustomField [value]", "Sprint custom field")
    .description('Create an issue or a sub-task')
    .action(function (options) {
      auth.setConfig(function (auth) {
        if (auth) {
          create.saveIssue({
            fields: {
              project: { id: options.project },
              parent: options.parrentTask ? { key: options.parrentTask } : undefined,

              issuetype: { id: options.type },
              summary: options.title,
              description: options.description,
              priority: { id: options.priority },
              assignee: { name: options.assignee },
              [options.sprintCustomField]: Number(options.sprint),
            }
          });
        }
      });
    });

  program
    .command('config')
    .description('Change configuration')
    .option('-c, --clear', 'Clear stored configuration')
    .action(function (options) {
      if (options.clear) {
        auth.clearConfig();
      } else {
        auth.setConfig();
      }
    }).on('--help', function () {
      console.log('  Config Help:');
      console.log();
      console.log('    Jira URL: https://foo.atlassian.net/');
      console.log('    Username: user (for user@foo.bar)');
      console.log('    Password: Your password');
      console.log();
    });

  program
    .command('sprint')
    .description('Works with sprint boards\n' +
                 'With no arguments, displays all rapid boards\n' +
                 'With -r argument, attempt to find a single rapid board ' +
                 'and display its active sprints\nWith both -r and -s arguments ' +
                 'attempt to get a single rapidboard/ sprint and show its issues. If ' +
                 'a single sprint board isnt found, show all matching sprint boards')
    .option('-r, --rapidboard <name>', 'Rapidboard to show sprints for', String)
    .option('-s, --sprint <name>', 'Sprint to show the issues', String)
    .action(function (options) {
      auth.setConfig(function (auth) {
        if (auth) {
          sprint(options.rapidboard, options.sprint);
        }
      });
    });

  program.parse(process.argv);

  if (program.args.length === 0) {
    auth.setConfig(function (auth) {
      if (auth) {
        program.help();
      }
    });
  }

});
