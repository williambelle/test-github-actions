#!/usr/bin/env bash

set -eo pipefail

API_HOST="https://api.github.com/repos"
MILESTONES_URL="$API_HOST/${GITHUB_REPOSITORY}/milestones?per_page=100"

echo -e ${GITHUB_REPOSITORY} 
if [ $(echo ${GITHUB_REPOSITORY} | wc -c) -eq 1 ] ; then
  echo -e "\033[31mRepository cannot be empty\033[0m"
  exit 1
fi

echo -e ${GITHUB_REF#refs/heads/}
echo -e $MILESTONES_URL

curl --silent --request GET \
  --url $MILESTONES_URL \
  --header "Authorization: Bearer ${token}"

NUMBER=`curl --silent --request GET \
  --url $MILESTONES_URL \
  --header "Authorization: Bearer ${token}" | jq -r ".[]|select(.title==\"v${GITHUB_REF#refs/heads/}\").number"`
echo -e $NUMBER


if [ $(echo $NUMBER | wc -c) -eq 1 ] ; then
  echo -e "\033[31mMilestone number cannot be empty\033[0m"
  exit 1
fi

curl --silent --request PATCH \
  --url $API_HOST/${GITHUB_REPOSITORY}/milestones/$NUMBER \
  --header "Authorization: Bearer ${token}" \
  --header 'Content-Type: application/json' \
  --data '{"state":"closed"}'