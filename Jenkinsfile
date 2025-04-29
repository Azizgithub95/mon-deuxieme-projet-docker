pipeline {
  agent any

  // Variables d’environnement partagées
  environment {
    DOCKER_HOST        = 'unix:///var/run/docker.sock'
    IMAGE_NAME         = 'aziztesteur95100/mon-deuxieme-projet-docker'
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
          steps {
            echo '--- Cypress tests ---'
            script {
              docker.image('cypress/included:12.17.4').inside {
                sh '''
                  npm ci --no-audit --progress=false
                  npx cypress install
                  npx cypress run
                '''
              }
            }
          }
        }
        stage('Newman') {
          steps {
            echo '--- Newman tests ---'
            script {
              docker.image('postman/newman:alpine').inside('--entrypoint=""') {
                sh 'pwd && ls -R .'
                sh '''
                  mkdir -p reports/newman
                  newman run collections/MOCK_AZIZ_SERVEUR.postman_collection.json \
                    --reporters cli,html \
                    --reporter-html-export reports/newman/newman-report.html
                '''
              }
            }
          }
        }
        stage('K6') {
          steps {
            echo '--- K6 tests ---'
            script {
              docker.image('grafana/k6').inside {
                sh 'pwd && ls -R .'
                sh '''
                  mkdir -p reports/k6
                  k6 run tests/test_k6.js
                '''
              }
            }
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      when { expression { currentBuild.currentResult == 'SUCCESS' } }
      steps {
        script {
          // Authentifie-toi et pousse deux tags : v1.0 + latest
          docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS}") {
            def img = docker.build("${IMAGE_NAME}:v1.0")
            img.push('v1.0')
            img.push('latest')
          }
        }
      }
    }
  }

  post {
    always {
      // Archive tous les rapports générés
      archiveArtifacts artifacts: 'reports/**', fingerprint: true
      // Envoie une notification par mail
      mail to: 'aziztesteur@hotmail.com',
           subject: "Build ${currentBuild.fullDisplayName} — ${currentBuild.currentResult}",
           body:  "Le build est ENFIN terminé avec le statut : ${currentBuild.currentResult}.\n" +
                  "Consulte tous les logs sur Jenkins."
    }
  }
}
