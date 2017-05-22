#!/bin/bash

# (10102) Sub-task
# (10200) Other-sub-task
# (10100) Story
# (10104) Test
# (10103) Bug
# (10000) Epic
# (10101) Other
# (10400) Task
# (10303) Change
# (1) Highest
# (2) High
# (3) Medium
# (4) Low
# (5) Lowest

ME=quangtrung
PROJECT_SE=10100
PRIORITY_MEDIUM=3
ISSUE_TYPE_TASK=10400
SPRINT_CUSTOM_FIELD_ID="customfield_10115"
ACTIVE_BOARD="7-Eleven Technical Board"

activeSprint() {
  jira sprint -r "$ACTIVE_BOARD" | egrep 'ACTIVE' | tr -s ' ' | cut -d '│' -f 2 | awk '{$1=$1};1'
}

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
fi

if [ "$1" == "activeSprint" ]
  then
  activeSprint
fi

if [ "$1" == "newTask" ]
  then

  if [ $# -eq 1 ]
    then
      echo "Please set task title"
    else
      echo "Get active sprint..."
      ACTIVE_SPRINT=$(activeSprint)
      echo "Creating issue for active sprint $ACTIVE_SPRINT..."
      jira new-issue -p $PROJECT_SE -r $PRIORITY_MEDIUM -y $ISSUE_TYPE_TASK -t "$2" -d "$2" -a $ME -l $SPRINT_CUSTOM_FIELD_ID -s $ACTIVE_SPRINT
      [ $? -eq 0 ] || exit $?;
      echo "Done!"
    fi
fi

# moveCard SE-1234 "HQ 1.2.13" nguyenvu
if [ "$1" == "moveCard" ]
  then

  if [ $# -eq 1 ]
    then
      echo "Please set issue number"
    else
      jira assign $2 $ME
      [ $? -eq 0 ] || exit $?;

      jira move $2 "Start Analysis"
      [ $? -eq 0 ] || exit $?;

      jira move $2 "Analysis Complete"
      [ $? -eq 0 ] || exit $?;

      jira move $2 "Developer Assigned"
      [ $? -eq 0 ] || exit $?;

      jira move $2 "Code Review"
      [ $? -eq 0 ] || exit $?;

      jira move $2 "Start Review"
      [ $? -eq 0 ] || exit $?;

      jira move $2 "Review Passed"
      [ $? -eq 0 ] || exit $?;

      jira move $2 "Deployed"
      [ $? -eq 0 ] || exit $?;

      jira comment $2 "Done at $3"
      [ $? -eq 0 ] || exit $?;

      jira assign $2 $4
      [ $? -eq 0 ] || exit $?;

      echo "Done!"
    fi
fi

