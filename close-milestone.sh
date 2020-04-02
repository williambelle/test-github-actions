#!/usr/bin/env sh

set -eo pipefail

$GITHUB_API_R="https://api.github.com/repos"
$MILESTONES_URL="$GITHUB_API_R/${GITHUB_REPOSITORY}/milestones?per_page=100"

if [ $(echo ${GITHUB_REPOSITORY} | wc -c) -eq 1 ] ; then
  echo -e "\033[31mRepository cannot be empty\033[0m"
  exit 1
fi

$NUMBER=`curl --url $MILESTONES_URL | jq -r ".[]|select(.title==\"v${GITHUB_REF}\").number"`

if [ $(echo $NUMBER | wc -c) -eq 1 ] ; then
  echo -e "\033[31mMilestone number cannot be empty\033[0m"
  exit 1
fi

curl --request PATCH \
  --url $GITHUB_API_R/${GITHUB_REPOSITORY}/milestones/$NUMBER \
  --header "Authorization: Bearer ${GITHUB_TOKEN}" \
  --header 'Content-Type: application/json' \
  --data '{"state":"closed"}'