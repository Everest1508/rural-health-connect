#!/bin/bash

# Script to create a new release
# Usage: ./scripts/create_release.sh [version] [message]
# Example: ./scripts/create_release.sh 1.0.0 "Initial release"

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <version> [release_message]"
    echo "Example: $0 1.0.0 'Initial release'"
    exit 1
fi

VERSION=$1
RELEASE_MESSAGE=${2:-"Release v${VERSION}"}
TAG="v${VERSION}"

echo "Creating release ${TAG}..."
echo "Message: ${RELEASE_MESSAGE}"

# Update version in pubspec.yaml
cd flutter_app
CURRENT_VERSION=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2)
CURRENT_BUILD=$(echo $CURRENT_VERSION | cut -d '+' -f 2)
NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_VERSION="${VERSION}+${NEW_BUILD}"

echo "Updating version from ${CURRENT_VERSION} to ${NEW_VERSION}"

# Update pubspec.yaml
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version:.*/version: ${NEW_VERSION}/" pubspec.yaml
else
    # Linux
    sed -i "s/^version:.*/version: ${NEW_VERSION}/" pubspec.yaml
fi

cd ..

# Commit version change
git add flutter_app/pubspec.yaml
git commit -m "Bump version to ${NEW_VERSION}" || echo "No changes to commit"

# Create and push tag
git tag -a "${TAG}" -m "${RELEASE_MESSAGE}"
git push origin main
git push origin "${TAG}"

echo ""
echo "Release ${TAG} created successfully!"
echo "GitHub Actions will automatically build the release."
echo ""
echo "To build manually, run:"
echo "  cd flutter_app && ./build_release.sh both"

