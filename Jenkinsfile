pipeline {
  agent any

  // Variables réutilisables
  environment {
    IMAGE_NAME = 'aziztesteur95100/mon-deuxieme-projet'
    DOCKER_CREDENTIALS = 'docker-hub-credentials'
  }

  stages {
    stage('Checkout SCM') {
      steps {
        checkout scm
      }
    }

    stage('Tests') {
      parallel {
        stage('Cypress') {
          agent { docker { image 'cypress/included:12.17.4' } }
          steps {
            sh 'npm ci --no-audit --progress=false'
            sh 'npx cypress run'
          }
        }

        stage('Newman') {
          agent { docker { image 'postman/newman:alpine' } }
          steps {
            sh 'npm ci --no-audit --progress=false'
            sh 'newman run MOCK_AZIZ_SERVEUR.postman_collection.json --reporters cli,html --reporter-html-export reports/newman/newman-report.html'
          }
        }

        stage('K6') {
          agent { docker { image 'grafana/k6' } }
          steps {
            sh 'mkdir -p reports/k6'
            sh 'k6 run test_k6.js'
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      steps {
        script {
          // Build l’image avec un tag basé sur le numéro de build Jenkins
          def img = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")

          // Authentification et push sur Docker Hub
          docker.withRegistry('https://registry.hub.docker.com', DOCKER_CREDENTIALS) {
            img.push()          // tag :${BUILD_NUMBER}
            img.push('latest')  // tag :latest
          }
        }
      }
    }
  }

  post {
    always {
      // Archive tous les rapports générés
     archiveArtifacts artifacts: 'reports/**',     fingerprint: true
    }
  }
}
