__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. ${__DIR}/production.sh
# Based on production ---^

export DEPLOY_ENV="$(basename "${BASH_SOURCE[0]}" .sh)"
#      ^--- But DEPLOY_ENV is still staging
