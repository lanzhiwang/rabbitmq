#!/usr/bin/env bash

set -x

# bash update.sh
# bash update.sh 3.8.12
# bash update.sh 3.8.12 3.8.10 3.8.5

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"
# readlink -f update.sh
# dirname /root/huzhi/rabbitmq/update.sh
# cd /root/huzhi/rabbitmq

./versions-learn.sh "$@"
# ./versions.sh
# ./versions.sh 3.8.12
# ./versions.sh 3.8.12 3.8.10 3.8.5

./apply-templates.sh "$@"
# ./apply-templates.sh
# ./apply-templates.sh 3.8.12
# ./apply-templates.sh 3.8.12 3.8.10 3.8.5
