pipeline {
  agent any

  environment {
    // Vos variables d’environnement, par ex. DOCKER_REGISTRY, IMAGE_NAME, etc.
    DOCKER_REGISTRY = 'mon-registry'
    IMAGE_NAME      = 'mon-deuxieme-projet-docker'
    TAG_LATEST      = 'latest'
    TAG_VERSION     = 'v1.0'
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
              // Vérifie que l'image est là
              sh "docker inspect -f . cypress/included:12.17.4"

              // Démarre le conteneur Cypress en désactivant son ENTRYPOINT
              docker.image('cypress/included:12.17.4')
                    .inside("--entrypoint=\"\" -u root") {
                sh 'npm ci --no-audit --progress=false'
                // Lance Cypress sans le flag -c
                sh 'npx cypress run --record=false'
              }
            }
          }
          post {
            always {
              archiveArtifacts artifacts: 'cypress/videos/**, cypress/screenshots/**', allowEmptyArchive: true
            }
          }
        }

        stage('Newman') {
          steps {
            script {
              sh "docker inspect -f . postman/newman:alpine"

              docker.image('postman/newman:alpine')
                    .inside("--entrypoint=\"\"") {
                // Installer le reporter HTML au besoin
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
              sh "docker inspect -f . grafana/k6"

              docker.image('grafana/k6')
                    .inside("--entrypoint=\"\"") {
                sh 'npm ci --no-audit --progress=false'
                sh '''
                  mkdir -p reports/k6
                  k6 run test_k6.js --summary-export=reports/k6/summary.json
                '''
              }
            }
          }
          post {
            always {
              archiveArtifacts artifacts: 'reports/k6/summary.json', allowEmptyArchive: true
            }
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      when {
        allOf {
          expression { currentBuild.currentResult == 'SUCCESS' }
        }
      }
      steps {
        sh '''
          docker build -t $DOCKER_REGISTRY/$IMAGE_NAME:$TAG_VERSION .
          docker tag $DOCKER_REGISTRY/$IMAGE_NAME:$TAG_VERSION $DOCKER_REGISTRY/$IMAGE_NAME:$TAG_LATEST
          docker push $DOCKER_REGISTRY/$IMAGE_NAME:$TAG_VERSION
          docker push $DOCKER_REGISTRY/$IMAGE_NAME:$TAG_LATEST
        '''
      }
    }
  }

  post {
    always {
      // Vous pouvez envoyer un email ou autre notification ici
      echo "Pipeline terminé avec le statut ${currentBuild.currentResult}"
    }
  }
}
