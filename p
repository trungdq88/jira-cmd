#!/bin/bash

# Reset
COLOR_RESET='\033[0m'       # Text Reset

COLOR_BLACK='\033[0;30m'        # Black
COLOR_RED='\033[0;31m'          # Red
COLOR_GREEN='\033[0;32m'        # Green
COLOR_YELLOW='\033[0;33m'       # Yellow
COLOR_BLUE='\033[0;34m'         # Blue
COLOR_PURPLE='\033[0;35m'       # Purple
COLOR_CYAN='\033[0;36m'         # Cyan
COLOR_WHITE='\033[0;37m'

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

if [ "$1" == "start" ]
then
  if [ $# -eq 1 ]
  then
    echo "Please set issue number"
    exit 1
  fi

  # Input: issue ID

  # Check current repo is clean
  if git status --porcelain | grep .; then
    echo Repo is dirty, please commit current changes before start a new task
    exit 1
  fi

  # Checkout master
  echo "Checking out latest commits from master"
  git checkout master && git pull

  ISSUE_ID="$2"
  ISSUE_SUMMARY=$(jira show $2 | grep -m1 Summary | cut -d '│' -f 3 | awk '{$1=$1};1')
  ISSUE_SUMMARY_SLUG=$(echo "$ISSUE_SUMMARY" | tr '[:upper:]' '[:lower:]' | sed -e 's/[^a-z0-9]/ /g' -e 's/  */-/g' -e 's/.{10,}//' | cut -c 1-50)
  BRANCH_NAME="$ISSUE_ID/$ISSUE_SUMMARY_SLUG"

  EXIST_BRANCH=$(git branch -v | grep "\s*\*$BRANCH_NAME")

  if git show-ref --quiet "refs/heads/$BRANCH_NAME";then
    echo -e "${COLOR_RED}Branch "$BRANCH_NAME" already exists ${COLOR_RESET}"
    exit 1
  fi

  # Create branch with name from issue ID
  echo "Creating branch: $BRANCH_NAME"
  git checkout -b "$BRANCH_NAME"

  echo "Pushing branch to all remotes..."
  # Push branch to all remotes
  git remote | xargs -L1 git push --all
  echo 'Done!'
fi

if [ "$1" == "commit" ]
then

  if git status --porcelain | grep .; then
    echo Repo is dirty, please commit current changes before start a new task
    # show git status
    git status
    echo -e "${COLOR_GREEN}[a = add all & commit] ${COLOR_BLUE}[c = cancel]${COLOR_RESET}"
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ac]' ;do true ;done )
    stty $old_stty_cfg
    if echo "$answer" | grep -iq "^a" ;then
      ISSUE_ID=$(git branch -v | grep '^*' | cut -d ' ' -f 2 | cut -d '/' -f 1)
      echo Add all and commit
      echo -ne "${COLOR_GREEN}Commit message (Enter = use issue $ISSUE_ID title): ${COLOR_RESET}"
      read answer
      git add --all
      if echo "$answer" | grep -iq "^$" ;then
        ISSUE_SUMMARY=$(jira show $ISSUE_ID | grep -m1 Summary | cut -d '│' -f 3 | awk '{$1=$1};1')
        git commit -m "[$ISSUE_ID] $ISSUE_SUMMARY"
      else
        git commit -m "[$ISSUE_ID] $answer"
      fi
    else
      echo Cancelled
    fi
    # [cancel][add all & commit]
    # Enter commit msg (empty = use issue title)
    # Prefix commit msg with issue number
    # commit & push
  else
    echo "There is nothing to commit"
  fi
fi

if [ "$1" == "done" ]
then
  # Input: issue ID, QA username
  ISSUE_ID=$2
  QA_USERNAME=$3

  if [ -z "$ISSUE_ID" ]
  then
    echo "Please set issue number"
    exit 1
  fi

  if [ -z "$QA_USERNAME" ]
  then
    echo "Please set QA username"
    exit 1
  fi

  # Check current clean, make sure current branch is not master
  if git status --porcelain | grep .; then
    echo Repo is dirty, please commit current changes before finishing a task
  fi

  CURRENT_BRANCH=$(git branch -v | grep "\s*\*" | cut -d ' ' -f 2)
  if echo "$CURRENT_BRANCH" | grep -iq "^master$" ;then
    echo "You are not suppose to run this command on master"
  fi

  # Run tests
  yarn test

  # Merge to master and create PR to production
  # Bump version (save the version number)
  # Push master with tags to all remotes
  # moveCard with the version number and QA username
  echo 'hello'
fi

