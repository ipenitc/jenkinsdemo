// pipeline {
//     agent any
//
//     options {
//         buildDiscarder(logRotator(numToKeepStr: '5'))
//     }
//
//     environment {
//         DOCKER_USER     = 'ipenitcdocker'
//         REPO_NAME       = 'jenkinsdemo'
//         IMAGE_NAME      = "${DOCKER_USER}/${REPO_NAME}"
//         CREDS_ID        = 'docker-hub-creds'
//         VERSION         = "1.0.${env.BUILD_NUMBER}"
//     }
//
//     stages {
//         stage('Checkout') {
//             steps {
//                 // Works now because the script is inside the repo!
//                 checkout scm
//             }
//         }
//
//         stage('Build & Push') {
//             steps {
//                 script {
//                     sh "docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest ."
//                     docker.withRegistry('', CREDS_ID) {
//                         sh "docker push ${IMAGE_NAME}:${VERSION}"
//                         sh "docker push ${IMAGE_NAME}:latest"
//                     }
//                 }
//             }
//         }
//     }
//
//     post {
//         always {
//             sh "docker rmi ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest || true"
//         }
//     }
// }

pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    environment {
        DOCKER_USER     = 'ipenitcdocker'
        REPO_NAME       = 'jenkinsdemo'
        IMAGE_NAME      = "${DOCKER_USER}/${REPO_NAME}"
        CREDS_ID        = 'docker-hub-creds'
        VERSION         = "1.0.${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Unit Tests') {
            steps {
                script {
                    try {
                        // Use a standard Java image to run the tests
                        // We mount the current folder (pwd) to /app inside the container
                        sh "docker run --rm -v ${env.WORKSPACE}:/app -w /app eclipse-temurin:17-jdk-jammy ./gradlew test --no-daemon"
                    } finally {
                        // Because we mounted the volume, the XML files are now in your workspace!
                        junit '**/build/test-results/test/*.xml'
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                // Now we build the final image (tests are already done)
                sh "docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest ."
            }
        }

        stage('Push to Hub') {
            steps {
                script {
                    docker.withRegistry('', CREDS_ID) {
                        sh "docker push ${IMAGE_NAME}:${VERSION}"
                    }
                }
            }
        }
    }
}