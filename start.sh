#!/bin/bash
cd `dirname $0`

if [ "$1" == "-i" ]; then
  exec erl -sname webot -pa $PWD/ebin $PWD/deps/*/ebin -boot start_sasl -s webot
elif [ "$1" == "-e" ]; then
  exec erl -sname webot -pa $PWD/ebin $PWD/deps/*/ebin
else
  exec erl -sname webot -pa $PWD/ebin $PWD/deps/*/ebin -boot start_sasl -s webot -detached
fi

