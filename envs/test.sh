__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. ${__DIR}/development.sh
# Based on development ---^

export DEPLOY_ENV="$(basename "${BASH_SOURCE[0]}" .sh)"
export NODE_ENV="test"
export DEBUG=*:*
