#!/bin/bash
# update-px-modules.sh

# UPDATE ALL PRONOVIX MODULES

# ----- CONSTANTS ------
declare -r MODULES_DIR='web/modules/devportal'
declare -r THEMES_DIR='web/themes/devportal'
declare -a modules
declare -a themes

for dir in ./${MODULES_DIR}/*/; do
    modules+=("$(basename "${dir}")")
done

for dir in ./${THEMES_DIR}/*/; do
    themes+=("$(basename "${dir}")")
done

function add_all_repositories {
    add_all_modules_repositories
    add_all_themes_repositories
}

function add_all_modules_repositories {
    for repo_name in ${modules[@]}
    do
        git remote add -f ${repo_name} git@bitbucket.org:pronovix/${repo_name}.git
    done
}

function add_all_themes_repositories {
    for repo_name in ${themes[@]}
    do
        git remote add -f ${repo_name} git@bitbucket.org:pronovix/${repo_name}.git
    done
}

function update_all_modules {
    for repo_name in ${modules[@]}
    do
        git fetch ${repo_name}
        git subtree pull -P ${MODULES_DIR}/${repo_name} --squash ${repo_name} 8.x-1.x
    done
}

function update_all_themes {
    for repo_name in ${themes[@]}
    do
        git fetch ${repo_name}
        git subtree pull -P ${THEMES_DIR}/${repo_name} --squash ${repo_name} 8.x-1.x
    done
}

git stash -u

add_all_repositories

update_all_modules
update_all_themes

git stash apply

docker-compose exec cli bash -c "composer update nothing"
