#!/bin/sh

if [ $# -eq 0 ]; then
  ../testrunner -threads=16 -verbose -root=./modules/custom -command="../bin/phpunit"
else
  ../bin/phpunit ${@}
fi
