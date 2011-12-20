#!/bin/bash
cd `dirname $0`

NAME=webot
NODE=${NAME}@`hostname -s`

if [ "$1" = "-i" ]; then
    exec erl -sname ${NAME} -pa $PWD/ebin $PWD/deps/*/ebin -boot start_sasl -s webot
elif [ "$1" = "-e" ]; then
    exec erl -sname ${NAME} -pa $PWD/ebin $PWD/deps/*/ebin
elif [ "$1" = "-d" ]; then
    erl_call -n ${NODE} -q
elif [ "$1" = "-s" ]; then
    STATUS=`erl_call -n ${NODE} -a 'erlang whereis [webot_sup]'`
    if [ ${STATUS} != "undefined" ]; then
	echo "${NAME} is running."
    else
	echo "${NAME} is not running."
    fi
else
  exec erl -sname webot -pa $PWD/ebin $PWD/deps/*/ebin -boot start_sasl -s webot -detached
fi
