```groovy
pipeline {
  agent none

  environment {
    REGISTRY   = "mon-registry"
    IMAGE_NAME = "mon-deuxieme-projet-docker"
    VERSION    = "v1.0"
    LATEST     = "latest"
  }

  stages {

    stage('Checkout') {
      agent any
      steps {
        checkout scm
      }
    }

    stage('Install dependencies') {
      agent any
      steps {
        sh 'npm ci --no-audit --progress=false'
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
            sh 'npm install -g newman'
            sh '''
              mkdir -p reports/newman
              newman run MOCK_AZIZ_SERVEUR.postman_collection.json --reporters cli
            '''
          }
          post {
            always {
              archiveArtifacts artifacts: 'reports/newman/**/*', allowEmptyArchive: true
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
            sh 'k6 run test_k6.js'
          }
        }

      }
    }

    stage('Build & Push Docker Image') {
      when {
        expression { currentBuild.currentResult == 'SUCCESS' }
      }
      agent any
      steps {
        script {
          def img = docker.build("${REGISTRY}/${IMAGE_NAME}:${VERSION}")
          docker.withRegistry("https://${REGISTRY}") {
            img.push()
            img.push(LATEST)
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
```
