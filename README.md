<p align="center">
 <h1 align="center">Drupal Starter Kit</h1>
</p>

This repository is using Amazee's containers.

## Requirements

- Git
- Docker

## Install and start pygmy

> Only on Linux and macOS.

To install `pygmy`, run `gem install pygmy`.

This is only needed if you don't already have `pygmy` installed.

Start pygmy: `pygmy up`

## Create a new project

``` shell
docker run --rm -it -v $PWD:/app composer \
 create-project Pronovix/devportal-starterkit \
 -s dev --ignore-platform-reqs $DEVPORTAL_NAME
```

This command will create the project files with the containers.
It is possible that there will be some error output about missing the `gd` extension.

These errors can be ignored.

## Setup the containers

- Copy `docker-compose.unix.yml` or `docker-compose.windows.yml` as `docker-compose.override.yml`, depending on the
  host operating system.
- Then run `docker-compose up --build -d`
- `docker-compose run --rm cli sh -c 'composer install'`

## Setup the site

- Create your settings.local.php file:
  `cp web/sites/example.settings.local.php web/sites/default/settings.local.php`
- Create your settings.php file:
  `cp web/sites/default/default.settings.php web/sites/default/settings.php`
- Uncomment the inclusion of `settings.local.php` from the bottom of `web/sites/default/settings.php`.
- Add the following code to settings.local.php:

If you use MariaDB:

```php
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
```

If you use Postgres:

```php
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
```

Add the following snippet as well.

Look up the lagoon project name from `docker-compose.yml`, and replace `$PROJECT` with it in the following snippet:

```php
$settings['trusted_host_patterns'] = [
  '^$PROJECT.docker.amazee.io$',
  '^nginx.$PROJECT.docker.amazee.io$',
  '^nginx$',
  '^localhost$',
];

if (!drupal_installation_attempted()) {
  $settings['cache']['default'] = 'cache.backend.redis';
  $settings['redis.connection']['host'] = 'redis';
  $settings['container_yamls'][] = 'modules/contrib/redis/example.services.yml';
  $settings['container_yamls'][] = 'modules/contrib/redis/redis.services.yml';
  $class_loader->addPsr4('Drupal\\redis\\', 'modules/contrib/redis/src');
  $settings['bootstrap_container_definition'] = [
    'parameters' => [],
    'services' => [
      'redis.factory' => [
        'class' => 'Drupal\redis\ClientFactory',
      ],
      'cache.backend.redis' => [
        'class' => 'Drupal\redis\Cache\CacheBackendFactory',
        'arguments' => ['@redis.factory', '@cache_tags_provider.container', '@serialization.phpserialize'],
      ],
      'cache.container' => [
        'class' => '\Drupal\redis\Cache\PhpRedis',
        'factory' => ['@cache.backend.redis', 'get'],
        'arguments' => ['container'],
      ],
      'cache_tags_provider.container' => [
        'class' => 'Drupal\redis\Cache\RedisCacheTagsChecksum',
        'arguments' => ['@redis.factory'],
      ],
      'serialization.phpserialize' => [
        'class' => 'Drupal\Component\Serialization\PhpSerialize',
      ],
    ],
  ];
}

$config_directories['sync'] = '../config/sync';
```

- Inside the `cli` container, run `drush si $PROFILE --account-name=admin --account-pass=admin` where `$PROFILE` can be
either `config_installer` (if you already have configuration inside-`config/sync`) or `standard` (completely new
project). Wait until your site gets installed. _(This step can be skipped if you would
like to import an existing database)._

While it is not strictly necessary to enable the redis module, it is recommended to do so.

## Import database and public files

### Import public files

- Extract the downloaded public files archive: `tar -zxvf files.tgz`
- Copy the content to the public files location: `sudo rsync -av --delete files/
/path/to/project/web/sites/default/files`

### Import database

- Copy the database to the project's web folder: `cp database.sql.gz /path/to/project`
- Go to the project directory: `cd /path/to/project`
- Import the database with drush: `docker-compose run --rm cli sh -c 'zcat database.sql.gz | drush sqlc'`.

## Usual commands

- `docker-compose run --rm cli sh`

  To run commands inside the container.

- `docker-compose up -d`

  Starts the containers.

- `docker-compose stop`

  Shuts down the containers (keeps the state).

- `docker-compose down`

  Destroys the containers (permanently deletes the state).

## Running Mailhog on Windows

As Windows does not support Pygmy (which handles Mailhog on Linux/Mac), Mailhog should be added
separately as container (see docker-compose.windows.yml). After installing it with `docker-compose up -d`
you can reach Mailhog by visiting http://localhost:8025/ in your browser.

## Debugging

### Fixing xdebug on Linux

Open `docker-compose.override.yml` and follow the instructions in the `cli` and `php` sections.

## Running tests (optional)

`docker-compose run --rm php sh -c 'cd web; ./test.sh'`
