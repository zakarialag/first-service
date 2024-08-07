pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'test'
        DOCKER_TAG = 'latest'
        SONARKUBE_ANALYSIS_IMAGE = 'test-analysis'
        NEXUS_URL = 'nexus.ntdc.fr'
        DOCKER_AUTH = 'nexus.ntdc.fr/docker-auth'
        NEXUS_REPO = 'docker' // used name which you have use in nexus to create docker repository
        NEXUS_CREDENTIALS_ID = 'nexus' //this is the id of nexus cred which you setup in global cred (user pass)
        PROJECT_SONARKUBE_DOCKERFILE = 'Dockerfile.maven'
        SERVICE_PORT = 9090
        NEXUS_CREDENTIALS_FILE_ID = 'c421f6bf-3ed5-4e67-8110-b278b4c2499f'
    }

    stages {

        stage('Build Docker Image for sonarkube Analysis and Nexus') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker build -f ${PROJECT_SONARKUBE_DOCKERFILE} -t ${SONARKUBE_ANALYSIS_IMAGE} ."
                    sh "docker run -d --name ${SONARKUBE_ANALYSIS_IMAGE} ${SONARKUBE_ANALYSIS_IMAGE}"
                }
            }
        }

        stage('Run sonarkube Analysis') {
            steps {
                script {
                    // Build the Docker image
                    sh "docker  exec ${SONARKUBE_ANALYSIS_IMAGE} /app/scanner.sh"
                }
            }
        }

        stage('Run Maven Deploy to Nexus') {
            steps {
                configFileProvider([configFile(fileId: "${NEXUS_CREDENTIALS_FILE_ID}", variable: 'mevansettings')]) {
                    script {
                        // Print the path of the mevansettings file to the console for verification

                        sh "echo Maven settings file path: $mevansettings"
                        
                        // Copy the mevansettings file into the Docker container
                        sh "docker cp $mevansettings ${SONARKUBE_ANALYSIS_IMAGE}:/app/mevansettings.xml"
                        
                        // Run the Maven command inside the Docker container
                        sh "docker exec ${SONARKUBE_ANALYSIS_IMAGE} mvn -s /app/mevansettings.xml clean deploy"
                    }
                }
            }
        }

        stage('Push Docker Image to Nexus') {
            steps {
                script {

                    sh "docker build -t ${NEXUS_URL}/${NEXUS_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG} ."
                    // Tag the image with the Nexus repository URL
                    
                    // Login to Nexus Docker Registry
                    withCredentials([usernamePassword(credentialsId: NEXUS_CREDENTIALS_ID, passwordVariable: 'NEXUS_PASS', usernameVariable: 'NEXUS_USER')]) {
                        sh "docker login -u ${NEXUS_USER} -p '${NEXUS_PASS}' ${DOCKER_AUTH}"   
                    }

                    // Push the image to Nexus
                    sh "docker push ${NEXUS_URL}/${NEXUS_REPO}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                }
            }
        }
        
        stage('Run Micorservice') {
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
            steps {
                script {
                    // Here add the image name which you have use name in first stage of sonarkube
                    sh "docker rm -f  ${SONARKUBE_ANALYSIS_IMAGE}"
                    sh "docker rmi  ${SONARKUBE_ANALYSIS_IMAGE}"
                }
            }
        }
    }
}
