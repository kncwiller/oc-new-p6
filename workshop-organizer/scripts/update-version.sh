#!/bin/sh

VERSION=$1

echo "Updating version to $VERSION"

# Maven
if [ -f "pom.xml" ]; then
  mvn versions:set -DnewVersion=$VERSION -DgenerateBackupPoms=false
fi

# Gradle (simple)
if [ -f "build.gradle" ]; then
  sed -i "s/^version = .*/version = '$VERSION'/" build.gradle
fi
