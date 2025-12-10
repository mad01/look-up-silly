#!/bin/bash

# Script to update version numbers in project.yml using yq
# Usage:
#   ./bump_version.sh                      # Bump build number by 1
#   ./bump_version.sh build 5              # Set build number to 5
#   ./bump_version.sh marketing 1.2.0      # Set marketing version to 1.2.0
#   ./bump_version.sh both 1.2.0 5         # Set both versions
#   ./bump_version.sh show                 # Show current versions
#
# Requires: yq (brew install yq)

set -e

PROJECT_FILE="project.yml"

if [ ! -f "$PROJECT_FILE" ]; then
    echo "Error: $PROJECT_FILE not found"
    exit 1
fi

if ! command -v yq &> /dev/null; then
    echo "Error: yq is not installed. Install with: brew install yq"
    exit 1
fi

# Get current versions using yq
get_current_build() {
    yq '.targets.LookUpSilly.info.properties.CFBundleVersion' "$PROJECT_FILE" | tr -d '"'
}

get_current_marketing() {
    yq '.targets.LookUpSilly.info.properties.CFBundleShortVersionString' "$PROJECT_FILE" | tr -d '"'
}

# Update CFBundleVersion for all targets
update_build() {
    local version="$1"
    yq -i ".targets.LookUpSilly.info.properties.CFBundleVersion = \"$version\"" "$PROJECT_FILE"
    yq -i ".targets.ShieldConfiguration.info.properties.CFBundleVersion = \"$version\"" "$PROJECT_FILE"
    yq -i ".targets.ShieldAction.info.properties.CFBundleVersion = \"$version\"" "$PROJECT_FILE"
}

# Update CFBundleShortVersionString for all targets
update_marketing() {
    local version="$1"
    yq -i ".targets.LookUpSilly.info.properties.CFBundleShortVersionString = \"$version\"" "$PROJECT_FILE"
    yq -i ".targets.ShieldConfiguration.info.properties.CFBundleShortVersionString = \"$version\"" "$PROJECT_FILE"
    yq -i ".targets.ShieldAction.info.properties.CFBundleShortVersionString = \"$version\"" "$PROJECT_FILE"
}

show_versions() {
    echo "Current versions in project.yml:"
    echo "  Marketing (CFBundleShortVersionString): $(get_current_marketing)"
    echo "  Build (CFBundleVersion): $(get_current_build)"
}

# Main logic
COMMAND=${1:-bump}
CURRENT_BUILD=$(get_current_build)
CURRENT_MARKETING=$(get_current_marketing)

case "$COMMAND" in
    bump)
        NEW_BUILD=$((CURRENT_BUILD + 1))
        echo "Bumping build number: $CURRENT_BUILD -> $NEW_BUILD"
        update_build "$NEW_BUILD"
        ;;
    
    build)
        NEW_BUILD=${2:?"Error: Please provide build number"}
        echo "Setting build number: $CURRENT_BUILD -> $NEW_BUILD"
        update_build "$NEW_BUILD"
        ;;
    
    marketing)
        NEW_MARKETING=${2:?"Error: Please provide marketing version (e.g., 1.2.0)"}
        echo "Setting marketing version: $CURRENT_MARKETING -> $NEW_MARKETING"
        update_marketing "$NEW_MARKETING"
        ;;
    
    both)
        NEW_MARKETING=${2:?"Error: Please provide marketing version (e.g., 1.2.0)"}
        NEW_BUILD=${3:?"Error: Please provide build number"}
        echo "Setting marketing version: $CURRENT_MARKETING -> $NEW_MARKETING"
        echo "Setting build number: $CURRENT_BUILD -> $NEW_BUILD"
        update_marketing "$NEW_MARKETING"
        update_build "$NEW_BUILD"
        ;;
    
    show)
        show_versions
        exit 0
        ;;
    
    *)
        echo "Usage:"
        echo "  $0              # Bump build number by 1"
        echo "  $0 build 5      # Set build number to 5"
        echo "  $0 marketing 1.2.0  # Set marketing version"
        echo "  $0 both 1.2.0 5     # Set both versions"
        echo "  $0 show         # Show current versions"
        exit 1
        ;;
esac

echo ""
show_versions
echo ""
echo "Run 'xcodegen' to regenerate the Xcode project."
