# Drupal starter kit

This repository is using Amazee's containers.

## Setup

### Install pygmy

* Run `gem install pygmy`

This is only needed if you don't already have `pygmy` installed.

### Setup the containers

* Clone the repository
* Run `grep -rn CHANGEME .` and change the `CHANGEME` string to the project's name.
* `composer install`
* Start pygmy: `pygmy up`
* Then run `docker-compose up --build -d`

### Setup the site

* Create your settings.local.php file: 
`sudo cp web/sites/example.settings.local.php web/sites/default/settings.local.php`
* Configure the database connection and trusted hosts by adding the following 
lines to settings.local.php:

If you use MariaDB:
```
$databases['default']['default'] = [
  'database' => 'drupal',
  'username' => 'drupal',
  'password' => 'drupal',
  'prefix' => '',
  'host' => 'mariadb',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
];
  
$settings['trusted_host_patterns'] = [
  '^CHANGEME.docker.amazee.io$',
  '^nginx.CHANGEME.docker.amazee.io$',
  '^nginx$',
];
```
If you use Postgres:
```
$databases['default']['default'] = [
  'database' => 'drupal',
  'username' => 'drupal',
  'password' => 'drupal',
  'prefix' => '',
  'host' => 'postgres',
  'port' => '5432',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\pgsql',
  'driver' => 'pgsql',
];
  
$settings['trusted_host_patterns'] = [
  '^CHANGEME.docker.amazee.io$',
  '^nginx.CHANGEME.docker.amazee.io$',
  '^nginx$',
];
```
* Run `drush si config_installer --account-name=admin --account-pass=admin` 
and wait until your site gets installed. _(This step can be skipped if you would 
like to import an existing database_).
  
## Import database and public files

### Import public files

* Extract the downloaded public files archive: `tar -zxvf files.tgz`
* Copy the content to the public files location: `sudo rsync -av --delete files/ 
/path/to/project/web/sites/default/files`

### Import database

* Extract the downloaded database archive: `gzip -d database.sql.gz`
* Copy the database to the project's web folder: `cp database.sql /path/to/project/web`
* Go to the project directory: `cd /path/to/project`
* Import the database with drush: `docker-compose run cli sh` then run
`cd web && drush sql-cli < database.sql`.
  
## Usual commands

* `docker-compose run cli sh`

  To run commands inside the container.
  
* `docker-compose up -d`

  Starts the containers.
  
* `docker-compose stop`

  Shuts down the containers (saves the state).
  
* `docker-compose down`

  Destroys the containers (cannot restore state).

## Running tests (optional)

`docker-compose run --rm php sh -c 'cd web; ./test.sh'`
