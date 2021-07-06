#!/usr/bin/env bash

set -x

# ./versions-learn.sh 3.8.12

# 需要根据 rabbitmq 版本增加对应的 otp 版本
declare -A otpMajors=(
	[3.8]='24'
	[3.8.12]='23'
)
# otpMajors=([3.8]='24' [3.8.12]='23')

# 需要根据 rabbitmq 版本增加对应的 openssl 版本，openssl 版本统一使用 1.1
declare -A opensslMajors=(
	[3.8]='1.1'
	[3.8.12]='1.1'
)
# opensslMajors=([3.8]='1.1' [3.8.12]='1.1')

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"
# readlink -f ./versions.sh
# dirname /root/huzhi/rabbitmq/versions.sh
# cd /root/huzhi/rabbitmq

# 打印数组的方法是 echo ${versions[*]} 或者 echo ${versions[@]}
versions=( "$@" )
echo ${versions[*]}
# echo ""
# echo 3.8.12 3.8.10 3.8.5
# echo 3.8.12

# 数组元素个数 ${#versions[@]}
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
	json='{}'
else
	json="$(< versions.json)"
fi
versions=( "${versions[@]%/}" )
echo ${versions[*]}
# echo 3.8.12

# [ 0 -eq 0 ]
# versions=(*/)
# json='{}'
# versions=("${versions[@]%/}")
# echo 3.8 3.8-rc

# [ 3 -eq 0 ]
# json="$(< versions.json)"
# versions=("${versions[@]%/}")
# echo 3.8.12

for version in "${versions[@]}"; do
	echo ${version}
	# 3.8.12
	export version
	rcVersion="${version%-rc}"
	echo ${rcVersion}
	# 3.8.12

	# version=3.8
	# rcVersion="${version%-rc}"
	# echo ${rcVersion}  // 3.8

	# version=3.8-rc
	# rcVersion="${version%-rc}"
	# echo ${rcVersion}  // 3.8

	# version=3.8.5
	# rcVersion="${version%-rc}"
	# echo ${rcVersion}  // 3.8.5

	# version=3.8-rc-1
	# rcVersion="${version%-rc}"
	# echo ${rcVersion}  // 3.8-rc-1

	rcGrepV='-v'
	if [ "$rcVersion" != "$version" ]; then
		rcGrepV=
	fi
	rcGrepV+=' -E'
	echo ${rcGrepV}
	# -v -E

	# rcGrepV = -v -E
	# rcGrepV = -E
	# rcGrepV = -v -E
	# rcGrepV = -v -E

	rcGrepExpr='beta|milestone|rc'

	githubTags=( $(
		git ls-remote --tags https://github.com/rabbitmq/rabbitmq-server.git \
			"refs/tags/v${rcVersion}"{'','.*','-*','^*'} \
			| cut -d'/' -f3- \
			| cut -d'^' -f1 \
			| grep $rcGrepV -- "$rcGrepExpr" \
			| sort -urV
	) )

	githubTags=(v3.8.12)
	echo ${githubTags[@]}
	# v3.8.12

	# git ls-remote --tags https://github.com/rabbitmq/rabbitmq-server.git 'refs/tags/v3.8.12' 'refs/tags/v3.8.12.*' 'refs/tags/v3.8.12-*' 'refs/tags/v3.8.12^*' | cut -d'/' -f3- | cut -d'^' -f1 | grep -v -E -- 'beta|milestone|rc' | sort -urV
	# v3.8.12

	# $ git ls-remote --tags https://github.com/rabbitmq/rabbitmq-server.git 'refs/tags/v3.8' 'refs/tags/v3.8.*' 'refs/tags/v3.8-*' 'refs/tags/v3.8^*' | cut '-d/' -f3- | cut '-d^' -f1 | grep -v -E -- 'beta|milestone|rc' | sort -urV
	# v3.8.19
	# v3.8.18
	# v3.8.17
	# v3.8.16
	# v3.8.15
	# v3.8.14
	# v3.8.13
	# v3.8.12
	# v3.8.11
	# v3.8.10
	# v3.8.9
	# v3.8.8
	# v3.8.7
	# v3.8.6
	# v3.8.5
	# v3.8.4
	# v3.8.3
	# v3.8.2
	# v3.8.1
	# v3.8.0

	fullVersion=
	githubTag=
	for possibleTag in "${githubTags[@]}"; do
		fullVersion="$(
			wget -qO- "https://github.com/rabbitmq/rabbitmq-server/releases/tag/$possibleTag" \
				| grep -oE "/rabbitmq-server-generic-unix-${rcVersion}([.-].+)?[.]tar[.]xz" \
				| head -1 \
				| sed -r "s/^.*(${rcVersion}.*)[.]tar[.]xz/\1/" \
				|| :
		)"
		if [ -n "$fullVersion" ]; then
			githubTag="$possibleTag"
			break
		fi
	done

	# wget -qO- https://github.com/rabbitmq/rabbitmq-server/releases/tag/v3.8.12 | grep -oE '/rabbitmq-server-generic-unix-3.8.12([.-].+)?[.]tar[.]xz' | head -1 | sed -r 's/^.*(3.8.12.*)[.]tar[.]xz/\1/'
	# 3.8.12

	# wget -qO- https://github.com/rabbitmq/rabbitmq-server/releases/tag/v3.8.19 | grep -oE '/rabbitmq-server-generic-unix-3.8([.-].+)?[.]tar[.]xz' | head -1 | sed -r 's/^.*(3.8.*)[.]tar[.]xz/\1/' || :
	# wget -qO- https://github.com/rabbitmq/rabbitmq-server/releases/tag/v3.8.12 | grep -oE '/rabbitmq-server-generic-unix-3.8([.-].+)?[.]tar[.]xz' | head -1 | sed -r 's/^.*(3.8.*)[.]tar[.]xz/\1/'

	fullVersion=3.8.12
	githubTag=v3.8.12

	if [ -z "$fullVersion" ] || [ -z "$githubTag" ]; then
		echo >&2 "warning: failed to get full version for '$version'; skipping"
		continue
	fi
	export fullVersion


	otpMajor="${otpMajors[$rcVersion]}"
	otpVersions=( $(
		git ls-remote --tags https://github.com/erlang/otp.git \
			"refs/tags/OTP-$otpMajor.*"\
			| cut -d'/' -f3- \
			| cut -d'^' -f1 \
			| cut -d- -f2- \
			| sort -urV
	) )
	# git ls-remote --tags https://github.com/erlang/otp.git 'refs/tags/OTP-23.*' | cut -d'/' -f3- | cut -d'^' -f1 | cut -d- -f2- | sort -urV
	# 23.3.4.4
	# 23.3.4.3
	# 23.3.4.2
	# 23.3.4.1
	# 23.3.4
	# 23.3.3
	# 23.3.2
	# 23.3.1
	# 23.3
	# 23.2.7.4
	# 23.2.7.3
	# 23.2.7.2
	# 23.2.7.1
	# 23.2.7
	# 23.2.6
	# 23.2.5
	# 23.2.4
	# 23.2.3
	# 23.2.2
	# 23.2.1
	# 23.2
	# 23.1.5
	# 23.1.4.1
	# 23.1.4
	# 23.1.3
	# 23.1.2
	# 23.1.1
	# 23.1
	# 23.0.4
	# 23.0.3
	# 23.0.2
	# 23.0.1
	# 23.0-rc3
	# 23.0-rc2
	# 23.0-rc1
	# 23.0

	# $ git ls-remote --tags https://github.com/erlang/otp.git 'refs/tags/OTP-24.*' | cut -d'/' -f3- | cut -d'^' -f1 | cut -d- -f2- | sort -urV
	# 24.0.3
	# 24.0.2
	# 24.0.1
	# 24.0-rc3
	# 24.0-rc2
	# 24.0-rc1
	# 24.0

	otpVersions=(23.2.6)


	otpVersion=
	for possibleVersion in "${otpVersions[@]}"; do
		if otpSourceSha256="$(
			wget -qO- "https://github.com/erlang/otp/releases/download/OTP-$possibleVersion/SHA256.txt" \
				| awk -v v="$possibleVersion" '$2 == "otp_src_" v ".tar.gz" { print $1 }'
		)"; then
			otpVersion="$possibleVersion"
			break
		fi
	done
	# wget -qO- https://github.com/erlang/otp/releases/download/OTP-23.2.6/SHA256.txt | awk -v v=23.2.6 '$2 == "otp_src_" v ".tar.gz" { print $1 }'
	# fd0d9228ca43c108dc09334e2e5fbf3c826b6beb5a53ba35818edb3c476836a7

	# wget -qO- https://github.com/erlang/otp/releases/download/OTP-24.0.3/SHA256.txt | awk -v v=24.0.3 '$2 == "otp_src_" v ".tar.gz" { print $1 }'
	# 64a70fb19da9c94d11f4e756998a2e91d8c8400d7d72960b15ad544af60ebe45

	otpSourceSha256=fd0d9228ca43c108dc09334e2e5fbf3c826b6beb5a53ba35818edb3c476836a7
	otpVersion=23.2.6
	if [ -z "$otpVersion" ]; then
		echo >&2 "warning: failed to get Erlang/OTP version for '$version' ($fullVersion); skipping"
		continue
	fi
	export otpVersion otpSourceSha256


	opensslMajor="${opensslMajors[$rcVersion]}"
	opensslVersion="$(
		wget -qO- 'https://www.openssl.org/source/' \
			| grep -oE 'href="openssl-'"$opensslMajor"'[^"]+[.]tar[.]gz"' \
			| sed -e 's/^href="openssl-//' -e 's/[.]tar[.]gz"//' \
			| sort -uV \
			| tail -1
	)"
	# wget -qO- https://www.openssl.org/source/ | grep -oE 'href="openssl-1.1[^"]+[.]tar[.]gz"' | sed -e 's/^href="openssl-//' -e 's/[.]tar[.]gz"//' | sort -uV | tail -1
	# 1.1.1k

	opensslVersion=1.1.1k
	if [ -z "$opensslVersion" ]; then
		echo >&2 "warning: failed to get OpenSSL version for '$version' ($fullVersion); skipping"
		continue
	fi

	opensslSourceSha256="$(wget -qO- "https://www.openssl.org/source/openssl-$opensslVersion.tar.gz.sha256")"
	# wget -qO- "https://www.openssl.org/source/openssl-1.1.1k.tar.gz.sha256"
	# 892a0875b9872acd04a9fde79b1f943075d5ea162415de3047c327df33fbaee5

	opensslSourceSha256=892a0875b9872acd04a9fde79b1f943075d5ea162415de3047c327df33fbaee5
	export opensslVersion opensslSourceSha256

	echo "$version: $fullVersion (otp $otpVersion, openssl $opensslVersion)"

	json="$(
		jq <<<"$json" -c '
			.[env.version] = {
				version: env.fullVersion,
				openssl: {
					version: env.opensslVersion,
					sha256: env.opensslSourceSha256,
				},
				otp: {
					version: env.otpVersion,
					sha256: env.otpSourceSha256,
				},
			}
		'
	)"
done

jq <<<"$json" -S . > versions.json
