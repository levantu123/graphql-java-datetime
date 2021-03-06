#!/usr/bin/env bash
ABSOLUTE_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${ABSOLUTE_PATH}" || exit

set -e

printf "> \e[1;37mBuilding graphql-java-datetime\e[0m\n"

appVersion=$(./version.sh)

printf "\n# Project version \e[1;37m$appVersion\e[0m"

rm -rf build

printf "\n# Checking for failed dependencies\n\n"
./gradlew dependencies | grep FAILED && exit 1

if [ -n "${ARTIFACTORY_CONTEXT_URL}" ] && [[ $appVersion != *"SNAPSHOT"* ]]; then
  printf "\n# Publishing plugin to Artifactory\n\n"
  ./gradlew -PprojectVersion="${appVersion}" clean jar sourcesJar generatePomFileForMainProjectPublicationPublication artifactoryPublish
elif [ -n "${BINTRAY_KEY}" ] && [[ $appVersion != *"SNAPSHOT"* ]]; then
  printf "\n# Publishing plugin to Bintray\n\n"
  ./gradlew -PprojectVersion="${appVersion}" clean jar sourcesJar javadocJar generatePomFileForMainProjectPublicationPublication
  ./gradlew -PprojectVersion="${appVersion}" bintrayUpload
else
  printf "# Installing locally\n\n"
  ./gradlew -PprojectVersion="${appVersion}" clean install -x javadoc -x test
fi
