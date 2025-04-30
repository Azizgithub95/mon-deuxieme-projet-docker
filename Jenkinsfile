pipeline {
  agent none

  environment {
    REGISTRY               = "mon-registry"
    IMAGE_NAME             = "mon-deuxieme-projet-docker"
    VERSION                = "v1.0"
    LATEST                 = "latest"
    DOCKER_CREDENTIALS_ID  = "docker-credentials-id"
  }

  stages {

    stage('Checkout') {
      agent any
      steps {
        checkout scm
      }
    }

    stage('Install dependencies') {
      agent {
        docker {
          image 'node:18'
          args  '--entrypoint="" -u root:root -v $HOME/.npm:/root/.npm'
        }
      }
      steps {
        // installe tout (Cypress, Newman, etc.) dans node_modules
        sh 'npm ci --no-audit --progress=false'
        // Newman peut être appelé en CLI via npx ; sinon installe-le globalement :
        sh 'npm install -g newman'
      }
    }

    stage('Tests (parallel)') {
      parallel {

        stage('Cypress') {
          agent {
            docker {
              image 'cypress/included:14.3.2'
              args  '--entrypoint=""'
            }
          }
          steps {
            // pas de npm ci ici, on réutilise le node_modules monté depuis le stage précédent
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
            sh '''
              mkdir -p reports/newman
              npx newman run MOCK_AZIZ_SERVEUR.postman_collection.json \
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
          docker.withRegistry("https://${REGISTRY}", "${DOCKER_CREDENTIALS_ID}") {
            img.push()
            img.push(LATEST)
          }
        }
      }
    }

  }

  post {
    always {
      echo "🔔 Pipeline encore terminé avec le statut : ${currentBuild.currentResult}"
    }
  }
}
