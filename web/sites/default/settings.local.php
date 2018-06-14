<?php

$config_directories['sync'] = '../config/sync';
$databases['default']['default'] = array (
  'database' => 'drupal',
  'username' => 'drupal',
  'password' => 'drupal',
  'prefix' => '',
  'host' => 'postgres',
  'port' => '5432',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\pgsql',
  'driver' => 'pgsql',
);
$settings['install_profile'] = 'standard';

$settings['trusted_host_patterns'] = [
  '^CHANGEME.docker.amazee.io$',
  '^nginx.CHANGEME.docker.amazee.io$',
  '^nginx$',
];

if (!drupal_installation_attempted()) {
   $settings['cache']['default'] = 'cache.backend.redis';
   $settings['redis.connection']['host'] = 'redis';
}
