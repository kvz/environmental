#!/usr/bin/env bash
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${__dir}/production.sh
# Based on production ---^

export DEPLOY_ENV="$(basename "${BASH_SOURCE[0]}" .sh)"
#      ^--- But DEPLOY_ENV is still staging
