# Function to increment the version number
increment_version() {
    local v=$1
    local prefix=""
    # Check if the version has a 'v' prefix and remove it
    if [[ $v == v* ]]; then
        prefix="v"
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

# Increment the version
NEW_VERSION=$(increment_version $VERSION)

# Update the version file with the new version
echo $NEW_VERSION > version.txt
echo "NEW_VERSION=${NEW_VERSION}" >> "$GITHUB_ENV"

