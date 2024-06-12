#!/bin/bash

base_sha=cc6d291d09d466f3b1f7da8c2abf0f76aa85d231
echo "Base sha $base_sha"
head_sha=21683236508613777e9b37dcffa67f7240689815
echo "Head sha $head_sha"
echo "---"
commits="$(git rev-list --ancestry-path $base_sha..$head_sha)"
echo "Analyzing:"
# while [ "$commit_sha" != "$head_sha" ]; do
for commit in $commits; do
dco_check=$(git show --no-patch --format="%B" "$commit" | grep 'Signed-off-by:')
if [ -z "$dco_check" ]; then
    echo "Commit $commit is missing the DCO sign-off!"
    exit 1
fi

echo "$commit passed"
done
echo "---"
echo "All commits have DCO signed-off"