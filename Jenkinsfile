pipeline {
  agent any

  environment {
    DOCKER_REGISTRY = 'mon-registry'
    IMAGE_NAME      = 'mon-deuxieme-projet-docker'
    TAG_VERSION     = 'v1.0'
    TAG_LATEST      = 'latest'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Tests') {
      parallel {
        stage('Cypress') {
          steps {
            script {
              docker.image('cypress/included:12.17.4').inside('--entrypoint=""') {
                sh 'npm ci --no-audit --progress=false'
                sh 'npx cypress run --record=false'
              }
            }
          }
          post {
            always {
              archiveArtifacts artifacts: 'cypress/videos/**,cypress/screenshots/**', allowEmptyArchive: true
            }
          }
        }

        stage('Newman') {
          steps {
            script {
              docker.image('postman/newman:alpine').inside('--entrypoint=""') {
                sh 'npm install -g newman-reporter-html'
                sh '''
                  mkdir -p reports/newman
                  newman run MOCK_AZIZ_SERVEUR.postman_collection.json \
                    --reporters cli,html \
                    --reporter-html-export reports/newman/newman-report.html
                '''
              }
            }
          }
          post {
            always {
              archiveArtifacts artifacts: 'reports/newman/**/*.html', allowEmptyArchive: true
            }
          }
        }

        stage('K6') {
          steps {
            script {
              docker.image('grafana/k6').inside('--entrypoint=""') {
                // Exécution du test K6 sans génération de rapport
                sh 'k6 run test_k6.js'
              }
            }
          }
          // Aucun archivage de rapport pour K6
        }
      }
    }

    stage('Build & Push Docker Image') {
      when {
        expression { currentBuild.currentResult == 'SUCCESS' }
      }
      steps {
        sh '''
          docker build -t $DOCKER_REGISTRY/$IMAGE_NAME:$TAG_VERSION .
          docker tag  $DOCKER_REGISTRY/$IMAGE_NAME:$TAG_VERSION $DOCKER_REGISTRY/$IMAGE_NAME:$TAG_LATEST
          docker push $DOCKER_REGISTRY/$IMAGE_NAME:$TAG_VERSION
          docker push $DOCKER_REGISTRY/$IMAGE_NAME:$TAG_LATEST
        '''
      }
    }
  }

  post {
    always {
      echo "Pipeline terminé enfin avec le statut : ${currentBuild.currentResult}"
    }
  }
}
