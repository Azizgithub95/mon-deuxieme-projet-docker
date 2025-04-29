pipeline {
  agent any

  environment {
    DOCKER_REGISTRY = 'mon-registry'
    IMAGE_NAME      = 'mon-deuxieme-projet-docker'
    TAG_VERSION     = 'v1.0'
    TAG_LATEST      = 'latest'
  }

  stages {
    stage('Checkout SCM') {
      steps {
        checkout scm
      }
    }

    stage('Tests (parallel)') {
      parallel {
        stage('Cypress') {
          agent {
            docker {
              image 'cypress/included:12.17.4'
              args  '--entrypoint=""'
            }
          }
          steps {
            sh 'npm ci --no-audit --progress=false'
            sh 'npx cypress run --record=false'
          }
          post {
            always {
              archiveArtifacts artifacts: 'cypress/videos/**,cypress/screenshots/**', allowEmptyArchive: true
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
            sh 'npm install -g newman-reporter-html'
            sh '''
              mkdir -p reports/newman
              newman run MOCK_AZIZ_SERVEUR.postman_collection.json \
                --reporters cli,html \
                --reporter-html-export reports/newman/newman-report.html
            '''
          }
          post {
            always {
              archiveArtifacts artifacts: 'reports/newman/**/*.html', allowEmptyArchive: true
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
            // juste exécuter le test, sans exporter ni archiver de rapport
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
          docker.build("${DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG_VERSION}")
          docker.withRegistry("https://${DOCKER_REGISTRY}") {
            docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG_VERSION}").push()
            docker.image("${DOCKER_REGISTRY}/${IMAGE_NAME}:${TAG_VERSION}").push("${TAG_LATEST}")
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
