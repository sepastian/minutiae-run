#!/bin/bash

set -euo pipefail

#set -x

cat <<EOF
Looking for credentials.json.
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
#read -p "Enter your Github username: " GITHUB_USERNAME
docker login ghcr.io || {
  cat <<-EOF
  Error logging in with Github, aborting.
  Login with ghcr.io first with:

  docker login ghcr.io

  Then run this script again.
EOF
  exit 1
}

echo "Pulling Docker images."
docker pull ghcr.io/sepastian/minutiae-pdf-service:2
docker pull ghcr.io/sepastian/minutiae-tz-resolver:2
docker pull redis:alpine

echo "Starting redis."
image="redis:alpine"
name="minutiae-redis"
docker run --rm --detach \
  --name "${name}" \
  "${image}" || {
    echo "Container ${name} exists."
    echo "Restarting container."
    docker restart "${name}"
  }

echo "Starting minutiae-tz-resolver."
  image="ghcr.io/sepastian/minutiae-tz-resolver:2"
  name="minutiae-tz-resolver"
  docker run --rm --detach \
    --name "${name}" \
    -v "${credentials_path}":/run/secrets/google_app_credentials \
    -e BUCKET_NAME=minutiae-production.appspot.com \
    -e GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/google_app_credentials \
    -e LOG_LEVEL=DEBUG \
    "${image}" || {
      echo "Container ${name} exists."
      echo "Restarting container."
      docker restart "${name}"
    }

echo "Starting minutiae-pdf-service."
image="ghcr.io/sepastian/minutiae-pdf-service:2"
name="minutiae-pdf-service"
docker run --rm --detach \
  --name "${name}" \
  -v "${credentials_path}":/run/secrets/google_app_credentials \
  -e BUCKET_NAME=minutiae-production.appspot.com \
  -e GOOGLE_APPLICATION_CREDENTIALS=/run/secrets/google_app_credentials \
  -e LOG_LEVEL=DEBUG \
  "${image}" || {
    echo "Container ${name} exists."
    echo "Restarting container."
    docker restart "${name}"
  }

# TODO: verify services are running.
docker ps

echo "Ready to render."

answer=""
while [[ $answer != "exit" ]]
do
    read -p "Type 'exit' + ENTER to stop all containers and exit. " answer
done
