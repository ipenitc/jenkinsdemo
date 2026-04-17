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
                         try {
                             // This will run the tests and likely fail (exit code 1)
                             sh "docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest ."
                         } finally {
                             // This block runs EVEN IF the build above failed
                             echo "Extracting test results..."
                             // 1. Create a dummy container to access the files inside
                             sh "docker create --name extract-${env.BUILD_NUMBER} ${IMAGE_NAME}:${VERSION} || true"
                             // 2. Copy the results out to the Jenkins workspace
                             sh "docker cp extract-${env.BUILD_NUMBER}:/app/build/test-results ./build/ || true"
                             // 3. Clean up the dummy container
                             sh "docker rm extract-${env.BUILD_NUMBER} || true"
                         }
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
                // This is what makes the "Tests" tab appear!
                junit 'build/test-results/**/*.xml'
                sh "docker rmi ${IMAGE_NAME}:${VERSION} ${IMAGE_NAME}:latest || true"
            }
        }
}