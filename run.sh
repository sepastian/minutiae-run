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

url='https://raw.githubusercontent.com/sepastian/minutiae-pdf-service-runner/main/docker-compose.yml'
cat << EOF

*****

Downloading docker-compose.yml from ${url}.
EOF
curl --silent "${url}" > docker-compose.yml
if [[ ! -f docker-compose.yml ]];
then
    cat <<-EOF
    Error fetching docker-compose.yml, aborting.
EOF
exit 1
fi

echo "Starting Docker containers."
docker-compose up --remove-orphans

echo "Done, bye!"
