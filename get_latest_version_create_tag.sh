#!/bin/bash

# Function to increment the version number
increment_version() {
    local v=$1
    local prefix="v"
    # Check if the version has a 'v' prefix and remove it
    if [[ $v == v* ]]; then
        v=${v#v}
    fi

    if [ -z "$v" ]; then
        echo "${prefix}1.0.0"
    else
        local part1=${v%.*} # contains everything before the last dot (.). For example, if v is 1.0.2, part1 will be 1.0.
        local part2=${v##*.} # contains everything after the last dot (.). For example, if v is 1.0.2, part2 will be 2.
        echo "${prefix}${part1}.$((part2+1))" # Increment patch by 1.
    fi
}

# Read the current version from the version file and trim any trailing newlines
VERSION=$(cat version.txt | tr -d '\n')
echo "Current version read from version.txt: $VERSION"

# Increment the version
NEW_VERSION=$(increment_version $VERSION)
echo "New version after incrementing: $NEW_VERSION"

# Update the version file with the new version
echo $NEW_VERSION > version.txt
echo "Updated version in version.txt: $NEW_VERSION"
echo "{NEW_VERSION}=$NEW_VERSION" >> "$GITHUB_ENV"
echo "Set NEW_VERSION=${NEW_VERSION} in GitHub environment"

# Setting local user and email
git config --local user.email "devwithkrishna-github-actions[bot]@users.noreply.github.com"
git config --local user.name "devwithkrishna github actions [bot]"

# Commit the version file update
git add version.txt
git status
git commit --author="devwithkrishna github actions [bot] <devwithkrishna-github-actions[bot]@users.noreply.github.com>" -m "Increment version to $NEW_VERSION"

# Tag the commit with the new version
git tag -a $NEW_VERSION -m "Release version $NEW_VERSION"

# Push the commit and the tag to the remote repository
git push origin main --follow-tags
