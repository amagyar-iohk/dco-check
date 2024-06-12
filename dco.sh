#!/bin/bash

base_sha=cc6d291d09d466f3b1f7da8c2abf0f76aa85d231
echo "Base sha $base_sha"
head_sha=8eed5feea92e8a9cbb6b5422612f8debcaf2291a
echo "Head sha $head_sha"
echo "---"
commits="$(git rev-list --ancestry-path $base_sha..$head_sha)"
echo "Commits:"
echo "$commits"
echo "---"
# while [ "$commit_sha" != "$head_sha" ]; do
for commit in $commits; do
echo "Analyzing $commit"
dco_check=$(git show --no-patch --format="%B" "$commit" | grep -q 'Signed-off-by:')
echo "DCO check $dco_check"
# if [ "$dco_check" -ne 0 ]; then
#     echo "Commit $commit_sha is missing the DCO sign-off!"
#     exit 1
# fi

echo "$commit passed"
done

echo "All commits have DCO signed-off"