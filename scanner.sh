#!/bin/bash

# Run SonarQube Scanner
sonar-scanner \
  -Dsonar.projectKey=python_project \
  -Dsonar.sources=., \
  -Dsonar.host.url=https://sonarkube.your-domain.com, \
  -Dsonar.login=sqp_your_sonar_token
