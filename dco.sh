#!/bin/bash

# Get the pull request number as an argument
pr_number="$1"

if [ -z "$pr_number" ]; then
  echo "Please provide the pull request number as an argument."
  exit 1
fi

# Fetch the pull request details using the GitHub API (requires personal access token)
# Replace 'YOUR_ACCESS_TOKEN' with your actual GitHub personal access token
# You can generate one at https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
pull_request_data=$(curl -sSL "https://api.github.com/repos/<USER>/<REPO>/pulls/$pr_number?access_token=YOUR_ACCESS_TOKEN")

# Extract the base and head commit SHAs from the pull request data
base_commit_sha=$(echo "$pull_request_data" | jq -r '.base.sha')
head_commit_sha=$(echo "$pull_request_data" | jq -r '.head.sha')

# Check for missing access token or invalid pull request number
if [ -z "$base_commit_sha" ] || [ -z "$head_commit_sha" ]; then
  echo "An error occurred fetching pull request details."
  exit 1
fi

# Clone the repository (shallow clone for efficiency)
git clone --depth 1 https://github.com/<USER>/<REPO>.git

# Checkout the base branch
cd <REPO>
git checkout "$base_commit_sha"

# Loop through each commit in the pull request range
commit_sha="$base_commit_sha"
while [ "$commit_sha" != "$head_commit_sha" ]; do
  # Check if the commit message contains the "Signed-off-by" line
  dco_check=$(git show --no-patch --format="%B" "$commit_sha" | grep -q 'Signed-off-by:')

  if [ "$dco_check" -ne 0 ]; then
    echo "Commit $commit_sha is missing the DCO sign-off!"
    exit 1
  fi

  # Move to the next commit
  commit_sha=$(git rev-parse --parents -f "$commit_sha" | head -n 1)
done

echo "All commits in pull request #$pr_number have the DCO sign-off!"

# Clean up (optional)
rm -rf <REPO>