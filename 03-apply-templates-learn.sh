#!/usr/bin/env bash

set -x

[ -f versions.json ]

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"
# readlink -f ./apply-templates.sh
# dirname /root/huzhi/rabbitmq/apply-templates.sh
# cd /root/huzhi/rabbitmq

jqt='.jq-template.awk'
if [ -n "${BASHBREW_SCRIPTS:-}" ]; then
	jqt="$BASHBREW_SCRIPTS/jq-template.awk"
elif [ "$BASH_SOURCE" -nt "$jqt" ]; then
	wget -qO "$jqt" 'https://github.com/docker-library/bashbrew/raw/5f0c26381fb7cc78b2d217d58007800bdcfbcfa1/scripts/jq-template.awk'
fi
# wget -qO .jq-template.awk https://github.com/docker-library/bashbrew/raw/5f0c26381fb7cc78b2d217d58007800bdcfbcfa1/scripts/jq-template.awk

if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
	eval "set -- $versions"
fi

generated_warning() {
	cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

for version; do
	export version

	for variant in alpine ubuntu; do
		export variant

		echo "processing $version/$variant ..."

		{
			generated_warning
			gawk -f "$jqt" "Dockerfile-$variant.template"
		} > "$version/$variant/Dockerfile"
		# gawk -f .jq-template.awk Dockerfile-alpine.template > 3.8.12/alpine/Dockerfile
		# gawk -f .jq-template.awk Dockerfile-ubuntu.template > 3.8.12/ubuntu/Dockerfile

		cp -a docker-entrypoint.sh "$version/$variant/"
		# cp -a docker-entrypoint.sh 3.8.12/alpine/
		# cp -a docker-entrypoint.sh 3.8.12/ubuntu/

		if [ "$variant" = 'alpine' ]; then
			sed -i -e 's/gosu/su-exec/g' "$version/$variant/docker-entrypoint.sh"
			# sed -i -e s/gosu/su-exec/g 3.8.12/alpine/docker-entrypoint.sh
		fi

		echo "processing $version/$variant/management ..."

		{
			generated_warning
			gawk -f "$jqt" Dockerfile-management.template
		} > "$version/$variant/management/Dockerfile"
		# gawk -f .jq-template.awk Dockerfile-management.template > 3.8.12/alpine/management/Dockerfile
		# gawk -f .jq-template.awk Dockerfile-management.template > 3.8.12/ubuntu/management/Dockerfile

	done
done
