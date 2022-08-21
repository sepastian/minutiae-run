#!/bin/bash

set -euo pipefail

cat <<EOF
Looking for ./credentials.json in current directory.
EOF
credentials_path="$(realpath ${PWD})/credentials.json"
if [[ ! -r "${credentials_path}" ]]; then
  echo "Cannot find ${credentials_path}, aborting."
  exit 1
fi
printf "Found ${credentials_path}.\n"

cat << EOF
Logging in with Github.

Simply press ENTER, if you are already logged in.

When asked for a password, enter your Personal Access Token (PAT).
If required, create a PAT by logging in with github.com, then select
Settings > Developer settings > Personal access tokens
and create a token with read 'read:packages' permission.
EOF
docker login ghcr.io || {
  cat <<-EOF
  Error logging in with Github, aborting.
  Login with ghcr.io first with:

  docker login ghcr.io

  Then run this script again.
EOF
  exit 1
}

url='https://raw.githubusercontent.com/sepastian/minutiae-pdf-service-runner/main/docker-compose.yml'
cat << EOF
Fetching docker-compose.yml.
EOF
wget --no-clobber "${url}"
if [[ ! -f docker-compose.yml ]];
then
    cat <<-EOF
    Error fetching docker-compose.yml, aborting.
EOF
exit 1
fi

echo "Done, bye!"
