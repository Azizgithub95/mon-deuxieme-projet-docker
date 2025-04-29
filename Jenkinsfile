pipeline {
    agent any
    environment {
        GIT_REPO         = 'https://github.com/Azizgithub95/mon-deuxieme-projet-docker.git'
        GIT_CREDENTIAL   = 'fa8021fb-9db2-4dec-abf5-c3aca0766855'
        DOCKER_CREDENTIAL= 'fa8021fb-9db2-4dec-abf5-c3aca0766855'
    }
    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'feature/parallel-tests-and-push',
                    url: "${GIT_REPO}",
                    credentialsId: "${GIT_CREDENTIAL}"
            }
        }
        stage('Tests') {
            parallel {
                stage('Cypress') {
                    agent {
                        docker {
                            image 'cypress/included:12.17.4'
                            args  '--entrypoint="" -u root'
                        }
                    }
                    steps {
                        sh 'npm ci --no-audit --progress=false'
                        sh 'npx cypress run --record=false'
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'cypress/results/screenshots/**/*.png, cypress/results/videos/**/*.mp4', allowEmptyArchive: true
                        }
                    }
                }
                stage('Newman') {
                    agent {
                        docker {
                            image 'postman/newman:alpine'
                            args  '--entrypoint=""'
                        }
                    }
                    steps {
                        sh 'npm ci --no-audit --progress=false'
                        sh 'mkdir -p reports/newman'
                        sh 'newman run MOCK_AZIZ_SERVEUR.postman_collection.json --reporters cli,html --reporter-html-export reports/newman/newman-report.html'
                    }
                    post {
                        always {
                            archiveArtifacts artifacts: 'reports/newman/*.html', allowEmptyArchive: true
                        }
                    }
                }
                stage('K6') {
                    agent {
                        docker {
                            image 'grafana/k6'
                            args  '--entrypoint=""'
                        }
                    }
                    steps {
                        // Lancement du test K6 sans génération de rapport
                        sh 'k6 run test_k6.js'
                    }
                }
            }
        }
        stage('Build & Push Docker Image') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                script {
                    docker.withRegistry('', "${DOCKER_CREDENTIAL}") {
                        def tag    = "mon-deuxieme-projet-docker:${env.BUILD_NUMBER}"
                        def img    = docker.build(tag)
                        img.push()
                        img.push('latest')
                    }
                }
            }
        }
    }
    post {
        always {
            echo "🔔 Pipeline terminé avec le statut : ${currentBuild.currentResult}"
        }
    }
}
