#!/bin/bash
cd `dirname $0`

NAME=webot
NODE=${NAME}@`hostname -s`

if [ "$1" == "-i" ]; then
  exec erl -sname ${NAME} -pa $PWD/ebin $PWD/deps/*/ebin -boot start_sasl -s webot
elif [ "$1" == "-e" ]; then
  exec erl -sname ${NAME} -pa $PWD/ebin $PWD/deps/*/ebin
elif [ "$1" == "-d" ]; then
  erl_call -n ${NODE} -q
else
  exec erl -sname webot -pa $PWD/ebin $PWD/deps/*/ebin -boot start_sasl -s webot -detached
fi

