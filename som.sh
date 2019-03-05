#!/bin/sh
SCRIPT_PATH=`dirname $0`
exec ${SCRIPT_PATH}/pharo ${SCRIPT_PATH}/awesom.image som "$@"
