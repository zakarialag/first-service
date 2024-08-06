pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'test'
        DOCKER_TAG = 'latest'
        SONARKUBE_ANALYSIS_IMAGE = 'test-analysis'
        NEXUS_URL = 'nexus.ntdc.fr'
        DOCKER_AUTH = 'nexus.ntdc.fr/docker-auth'
        NEXUS_REPO = 'test'
        NEXUS_CREDENTIALS_ID = 'nexus'
        PROJECT_SONARKUBE_DOCKERFILE = 'Dockerfile.maven'
        SERVICE_PORT = 8086
        // SONARQUBE_URL = 'https://sonarkube.ntdc.fr'
        // SONARQUBE_TOKEN = 'sqp_2480648eff1dea5c4a482267310b3ff78245fb8a'
        // SONARKUBE_PROJECT_NAME = 'devops-test'
    }

    stages {
        stage('Build Docker Image for sonarkube Analysis') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker build -f ${PROJECT_SONARKUBE_DOCKERFILE} -t ${SONARKUBE_ANALYSIS_IMAGE} ."
                    sh "docker run -d --name ${SONARKUBE_ANALYSIS_IMAGE} ${SONARKUBE_ANALYSIS_IMAGE}"
                }
            }
        }

        stage('Run Maven Deploy to Nexus') {
            steps {
                configFileProvider([configFile(fileId: 'c421f6bf-3ed5-4e67-8110-b278b4c2499f', variable: 'mevansettings')]) {
                    script {
                        // Print the path of the mevansettings file to the console for verification
                        sh "echo Maven settings file path: $mevansettings"
                        
                        // Copy the mevansettings file into the Docker container
                        sh "docker cp $mevansettings test:/app/mevansettings.xml"
                        
                        // Run the Maven command inside the Docker container
                        sh "docker exec test mvn -s /app/mevansettings.xml clean deploy"
                    }
                }
            }
        }

        stage('Push Docker Image to Nexus') {
            steps {
                script {
                    // Tag the image with the Nexus repository URL
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${NEXUS_URL}/${NEXUS_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                    
                    // Login to Nexus Docker Registry
                    withCredentials([usernamePassword(credentialsId: NEXUS_CREDENTIALS_ID, passwordVariable: 'NEXUS_PASS', usernameVariable: 'NEXUS_USER')]) {
                        sh "docker login -u ${NEXUS_USER} -p ${NEXUS_PASS} ${DOCKER_AUTH}"
                    }

                    // Push the image to Nexus
                    sh "docker push ${NEXUS_URL}/${NEXUS_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('Run Microservice') {
            steps {
                script {
                    // Tag the image with the Nexus repository URL
                    sh "docker run -d -p ${SERVICE_PORT}:${SERVICE_PORT} ${NEXUS_URL}/${NEXUS_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
    }
    
    post {
        always {
            script {
                // Clean up the Docker container and image
                sh "docker rm -f ${SONARKUBE_ANALYSIS_IMAGE}"
                sh "docker rmi ${SONARKUBE_ANALYSIS_IMAGE}"
            }
        }
    }
}