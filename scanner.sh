#!/bin/bash

mvn clean verify sonar:sonar \
  -Dsonar.projectKey=test \
  -Dsonar.projectName='test' \
  -Dsonar.host.url=https://sonarkube.ntdc.fr \
  -Dsonar.token=sqp_43710482cf101e103e997f8fe896dc1333789a69
