#!/usr/bin/env bash
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${__dir}/_default.sh
# Based on _default ---^

export DEPLOY_ENV="$(basename "${BASH_SOURCE[0]}" .sh)"
export NODE_ENV="development"
export DEBUG=*:*

export MYAPP_REDIS_HOST="127.0.0.1"
export MYAPP_REDIS_PORT="6379"
export MYAPP_REDIS_PASS=""
