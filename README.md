# Drupal starter kit

This repository is using Amazee's containers.

## Setup

### Install pygmy

* `gem install pygmy`
* `pygmy up`

This is only needed if you don't already have `pygmy` installed.

### Setup the site

* Clone the repository
* Run `grep -rn CHANGEME .` and change the `CHANGEME` string to the project's name.
* `composer install`
* `docker-compose up --build -d`

## Running tests

`docker-compose run --rm php sh -c 'cd web; ./test.sh'`
