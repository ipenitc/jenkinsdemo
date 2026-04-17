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
    options { buildDiscarder(logRotator(numToKeepStr: '5')) }
    environment {
        DOCKER_USER     = 'ipenitcdocker'
        REPO_NAME       = 'jenkinsdemo'
        IMAGE_NAME      = "${DOCKER_USER}/${REPO_NAME}"
        CREDS_ID        = 'docker-hub-creds'
        VERSION         = "1.0.${env.BUILD_NUMBER}"
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Build & Test') {
            steps {
                script {
                    // Build runs the tests (ensure Dockerfile does NOT have -x test)
                    sh "docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest ."

                    // Extract results for Jenkins UI
                    sh "docker create --name extract-${env.BUILD_NUMBER} ${IMAGE_NAME}:${VERSION}"
                    sh "docker cp extract-${env.BUILD_NUMBER}:/app/build/test-results ./build/"
                    sh "docker rm extract-${env.BUILD_NUMBER}"
                }
            }
        }
        stage('Push to Hub') {
            steps {
                script {
                    docker.withRegistry('', CREDS_ID) {
                        sh "docker push ${IMAGE_NAME}:${VERSION}"
                        sh "docker push ${IMAGE_NAME}:latest"
                    }
                }
            }
        }
    }
    post {
        always {
            // Tell Jenkins where to find the extracted XML files
            junit 'build/test-results/**/*.xml'
            sh "docker rmi ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest || true"
        }
    }
}