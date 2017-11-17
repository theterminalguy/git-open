#!bin/sh

HOST=${1:-github.com}

check_if_git_repository(){
  inside_git_repo=$(git rev-parse --is--inside-work-tre 2>/dev/null)

  if ! [ "$inside_git_repo" ]; then
    echo "Not a git repo"

    exit 64
  fi
}

check_if_remote_configured(){
  remotes=$(git remote -v)

  if ! [[ "$remotes" ]]; then
    echo "You have no remotes configured"

    exit 65
  fi
}

check_if_current_branch_exist_on_remote(){
  branch_exist="$(git branch -r --contains) $(current_branch)"

  if ! [[ "$branch_exist" ]]; then
    echo "Branch $(current_branch) does not exist on remote."
    echo "Try git fetch [REMOTE_NAME] or git push -u [REMOTE_NAME] $(current_branch)"
    echo "and then try running the command again"

    exit 64
  fi
}

current_branch(){
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

current_branch_url(){
  echo "$(git remote -v | grep -E "push|fetch" | \
    grep "${HOST}" | head -1 | cut -f2 | \
    cut -d' ' -f1 | sed -e's/git@/http:\/\//' -e's/\.git$//')"
}

remote_url(){
  echo "$(current_branch_url)/tree/$(current_branch 2>/dev/null)"
}

check_if_git_repository
check_if_remote_configured
check_if_current_branch_exist_on_remote
current_branch_url
open $(remote_url)
