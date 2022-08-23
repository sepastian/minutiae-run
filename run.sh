#!/bin/sh

set -eu

ok="\033[32m✓ "
err="\033[31m✕ "
inf="\033[34m➔ "
end="\033[0m"

echo "${inf}Looking for ./credentials.json in current directory.${end}"
credentials_path="$( cd $(dirname ${0}); pwd -P )/credentials.json"
if [ ! -r "${credentials_path}" ]; then
  echo "${err}Cannot find ${credentials_path}, aborting.${end}"
  exit 1
fi
echo "${ok}Found ${credentials_path}.${end}"

url='https://raw.githubusercontent.com/sepastian/minutiae-pdf-service-runner/main/docker-compose.yml'
echo "${inf}Downloading docker-compose.yml from ${url}.${end}"
curl --silent "${url}" > docker-compose.yml
if [ ! -f docker-compose.yml ];
then
    echo "${err}Error fetching docker-compose.yml, aborting.${end}"
    exit 1
fi

echo "${inf}Starting Docker containers.${end}"
docker-compose pull
docker-compose up

echo "${inf}Done, bye!${end}"
