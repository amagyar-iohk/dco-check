#!/bin/bash

base_sha=4935183d70b200d9d6b56e0f9d92c34412083a1b
echo "Base sha $base_sha"
head_sha=7214b6c2a32eee5f743856c50fb90f4d7b4687d6
echo "Head sha $head_sha"
echo "---"
echo "Analyzing:"
fail=0
dco_check="$(git show --no-patch --format="%B" "$base_sha" | grep 'Signed-off-by:')"
if [ -z "$dco_check" ]; then
    echo "Commit $base_sha is missing the DCO sign-off!"
    fail=1
fi
echo "$base_sha passed"

commits="$(git rev-list --ancestry-path $base_sha..$head_sha)"
for commit in $commits; do
dco_check="$(git show --no-patch --format="%B" "$commit" | grep 'Signed-off-by:')"
if [ -z "$dco_check" ]; then
    printf "\e[31m$commit failed\e[0m\n"
    fail=1
else
    echo "$commit passed"
fi
done
if [ "$fail" -ne 0 ]; then
    echo "Failures found"
    exit 1
fi

echo "---"
echo "All commits have DCO signed-off"