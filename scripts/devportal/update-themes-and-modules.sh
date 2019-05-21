#!/bin/bash

# update-themes-and-modules.sh
# UPDATE ALL PRONOVIX MODULES AND THEMES.

# ----- CONSTANTS ------
declare -r MODULES_DIR='web/modules/devportal'
declare -r THEMES_DIR='web/themes/devportal'
declare -a modules
declare -a themes
declare -r DEVPORTAL_REMOTE_REPOSITORY_URL=${DEVPORTAL_REMOTE_REPOSITORY_URL-:"git@bitbucket.org:pronovix"}

if [[ -d ${MODULES_DIR} ]]; then
  for dir in $(find ${MODULES_DIR} -mindepth 1 -maxdepth 1 -type d); do
    modules+=( "$(basename "${dir}")" )
  done
fi

if [[ -d ${THEMES_DIR} ]]; then
  for dir in $(find ${THEMES_DIR} -mindepth 1 -maxdepth 1 -type d); do
    echo $dir;
    themes+=( "$(basename "${dir}")" )
  done
fi

function add_all_repositories {
  add_all_modules_repositories
  add_all_themes_repositories
}

function add_all_modules_repositories {
  for repo_name in ${modules[@]}
  do
    register_repository ${repo_name}
  done
}

function add_all_themes_repositories {
  for repo_name in ${themes[@]}
  do
    register_repository ${repo_name}
  done
}

function register_repository {
  local repo_name=$1
  git remote get-url ${repo_name} &> /dev/null
  if [[ $? -gt 0 ]]; then
    git remote add -f ${repo_name} ${DEVPORTAL_REMOTE_REPOSITORY_URL}/${repo_name}.git
  fi
}

function update_all_modules {
  for repo_name in ${modules[@]}
  do
    pull_latest_tag ${repo_name} ${MODULES_DIR}
  done
}

function update_all_themes {
  for repo_name in ${themes[@]}
  do
    pull_latest_tag ${repo_name} ${THEMES_DIR}
  done
}

function pull_latest_tag {
  local repo_name=$1
  local directory=$2
  git fetch ${repo_name}
  git ls-remote --tags --refs -q --exit-code ${repo_name} > /dev/null
  if [[ $? -eq 0 ]]; then
    # Extract "8.x-1.0-alpha1" from "refs/tags/8.x-1.0-alpha1".
    local latest_tag=$(git ls-remote --tags --refs ${repo_name} | tail -n 1 | awk -F '/' '{print $3}')
    git subtree pull --prefix=${directory}/${repo_name} --squash ${repo_name} ${latest_tag} -m "${repo_name} ${latest_tag}"
  else
    echo -e "${repo_name} does not have any tagged release.\n"
  fi
}

git stash -u

add_all_repositories

update_all_modules
update_all_themes

git stash apply

docker-compose exec cli bash -c "composer update nothing"
