<?php

namespace DevportalStarterKit\composer;

use Composer\Script\Event;

class ComposerScripts {

  public static function initializeProject(Event $event): void {
    $io = $event->getIO();

    $name = basename(realpath('.'));

    $parts = preg_split('#[/_-]#', $name);
    if (count($parts) === 0) {
      $io->writeError('<error>Unable to determine short project name.</error>');
      exit(1);
    }

    $short_name = $parts[count($parts)-1];

    $files = [
      'docker-compose.yml',
      'docker-compose.tests.yml',
    ];

    foreach ($files as $file) {
      file_put_contents($file,
        str_replace('CHANGEME', $short_name, file_get_contents($file)));
    }

    if (file_exists('.gitignore')) {
      unlink('.gitignore');
    }
    if (file_exists('.gitignore.project')) {
      rename('.gitignore.project', '.gitignore');
    }
  }

}
