pipeline {
  agent any
  environment {
    DOCKER_HOST = 'unix:///var/run/docker.sock'
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
                // debug : liste tout pour vérifier la présence de collections/
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
                // debug : liste tout pour yuyyt vérifier la présence de tests/
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
          docker.withRegistry('https://your-registry.example.com', 'credentialsId') {
            def img = docker.build("mon-deuxieme-projet:${env.BUILD_NUMBER}")
            img.push()
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'reports/**', fingerprint: true
      mail to: 'aziztesteur@hotmail.com',
           subject: "Build ${currentBuild.fullDisplayName}",
           body: "Statut: ${currentBuild.currentResult} — Voir les logs sur Jenkins."
    }
  }
}
