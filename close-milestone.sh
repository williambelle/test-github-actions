#!/usr/bin/env bash

set -eo pipefail

# Check if the GitHub repository is defined
if [ $(echo ${GITHUB_REPOSITORY} | wc -c) -eq 1 ] ; then
  echo -e "\033[31mRepository cannot be empty\033[0m"
  exit 1
fi

# Check if the GitHub branch or tag ref is defined
if [ $(echo ${GITHUB_REF} | wc -c) -eq 1 ] ; then
  echo -e "\033[31mBranch or tag cannot be empty\033[0m"
  exit 1
fi

# Build the url to our repository
API_REPO_URL="https://api.github.com/repos/${GITHUB_REPOSITORY}"

# This only works for up to 100 milestones because of API response pagination
#
# See:
#   - https://developer.github.com/v3/#pagination
#   - https://developer.github.com/v3/issues/milestones/
MILESTONES_URL="${API_REPO_URL}/milestones?per_page=100"

# Extract tag number
# The `GITHUB_REF` variable has the value `refs/tags/x.x.x`
TAG=${GITHUB_REF#refs/tags/}

# Get the list of opened milestones
MILESTONES_LIST=` \
  curl \
    --silent \
    --request GET \
    --url $MILESTONES_URL \
    --header "Authorization: Bearer ${GITHUB_TOKEN}"`

# Extract milestone number based on tag
M_NUM=`echo $MILESTONES_LIST | jq -r ".[]|select(.title==\"v${TAG}\").number"`

# Check if the number of the milestone is defined
if [ $(echo ${M_NUM} | wc -c) -eq 1 ] ; then
  echo -e "\033[31mMilestone number cannot be empty\033[0m"
  exit 1
fi

# Close the milestone
curl \
  --silent \
  --request PATCH \
  --url ${API_REPO_URL}/milestones/${M_NUM} \
  --header "Authorization: Bearer ${GITHUB_TOKEN}" \
  --header 'Content-Type: application/json' \
  --data '{"state":"closed"}'