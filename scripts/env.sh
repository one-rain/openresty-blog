#!/usr/bin/env bash

CLEAN_FLAG=1

function info() {
  if [ ${CLEAN_FLAG} -ne 0 ]; then
    local msg=$1
    echo "`date +"%Y-%m-%d %H:%M:%S"` Info: $msg" >&2
  fi
}

function warn() {
  if [ ${CLEAN_FLAG} -ne 0 ]; then
    local msg=$1
    echo "`date +"%Y-%m-%d %H:%M:%S"` Warning: $msg" >&2
  fi
}

function error() {
  local msg=$1
  local exit_code=$2

  echo "`date +"%Y-%m-%d %H:%M:%S"` Error: $msg" >&2

  if [ -n "$exit_code" ] ; then
    exit $exit_code
  fi
}
