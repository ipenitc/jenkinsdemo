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
                        // 1. Give execution permission to the wrapper
                        sh "chmod +x gradlew"
                        // 2. Run tests directly on the Jenkins agent
                        sh "./gradlew test"
                    } finally {
                        // This ensures that even if tests fail,
                        // Jenkins tries to read the results for the UI
                        junit '**/build/test-results/test/*.xml'
                    }
                }
            }
        }

        stage('Docker Build') {
            // This stage only runs if the 'Unit Tests' stage passes
            steps {
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