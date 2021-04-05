#!/usr/bin/env bash

echo "Entering /dubbo"
pushd /dubbo

./mvnw --batch-mode --update-snapshots --errors --no-transfer-progress clean install -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 -Dmaven.wagon.http.retryHandler.count=5 -DskipTests=false -DskipIntegrationTests=false -Dcheckstyle.skip=false -Drat.skip=false -Dmaven.javadoc.skip=true

STATUS=$?
echo "Dubbo build status: $STATUS"

if [[ $STATUS -ne 0 ]]; then
  echo "Dubbo build failed!"
  exit 1
fi

REVISION=`awk '/<revision>[^<]+<\/revision>/{gsub(/<revision>|<\/revision>/,"",$1);print $1;exit;}' pom.xml`
echo "Detected Dubbo version: '$REVISION'"
popd

echo "Entering /dubbo-spring-boot-project"
pushd /dubbo-spring-boot-project

./mvnw --batch-mode --errors --no-transfer-progress clean install -Drevision=$REVISION -Dmaven.test.skip=true -Dmaven.test.skip.exec=true

STATUS=$?
echo "Dubbo Spring Boot status: $STATUS"

if [[ $STATUS -ne 0 ]]; then
  echo "Dubbo Spring Boot build failed!"
  exit 1
fi

popd
