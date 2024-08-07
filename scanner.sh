#!/bin/bash

# Run SonarQube Scanner
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=test \
  -Dsonar.projectName='test' \
  -Dsonar.host.url=https://sonarkube.ntdc.fr \
  -Dsonar.token=test
