#!/bin/sh

if [[ $# -eq 0 ]]; then
  if [[ ! -d ../vendor ]]; then
    cd ..
    composer install
    cd web
  fi

  mkdir -p sites/simpletest/browser_output
  chmod 777 sites/simpletest/browser_output

  if ! drush status --fields=bootstrap | grep -q "Successful"; then
    drush si -y config_installer
  else
    echo "Site is already installed."
  fi

  if [[ -e /app/junit.xml ]]; then
    rm /app/junit.xml
  fi

  mkfifo /tmp/junit-pipe
  while true; do cat /tmp/junit-pipe >> /app/junit.xml; done &
  ../testrunner -threads=16 -verbose -root=./modules/custom -command="../vendor/bin/phpunit"
  kill %1

  sed -i 's#</*testsuites>##' /app/junit.xml
  sed -i 's#<?xml version="1.0" encoding="UTF-8"?>##' /app/junit.xml
  echo '<?xml version="1.0" encoding="UTF-8"?><testsuites>' >> junit-tmp.xml
  cat /app/junit.xml >> junit-tmp.xml
  echo "</testsuites>" >> junit-tmp.xml
  mv junit-tmp.xml /app/junit.xml
else
  php -d xdebug.idekey=PHPSTORM -d xdebug.remote_autostart=1 -d xdebug.remote_host=$DOCKERHOST ../vendor/bin/phpunit ${@}
fi
