pipeline {
  agent any

  environment {
    IMAGE_NAME         = 'aziztesteur95100/mon-deuxieme-projet'
    DOCKER_CREDENTIALS = 'docker-hub-credentials'
    DOCKER_HOST        = 'unix:///var/run/docker.sock'
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
            echo '--- Newman tests (with HTML reporter) ---'
            script {
              docker.image('postman/newman:alpine').inside('--entrypoint=""') {
                sh '''
                  # Installer le reporter HTML
                  npm install -g newman-reporter-html

                  mkdir -p reports/newman
                  newman run MOCK_AZIZ_SERVEUR.postman_collection.json \
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
                sh '''
                  mkdir -p reports/k6
                  k6 run test_k6.js
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
          docker.withRegistry('https://index.docker.io/v1/', "${DOCKER_CREDENTIALS}") {
            def img = docker.build("${IMAGE_NAME}:v1.0")
            img.push()
            img.push('latest')
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'reports/**', fingerprint: true

      mail to: 'aziz.aidel@hotmail.fr',
           subject: "Build ${currentBuild.fullDisplayName} — ${currentBuild.currentResult}",
           body: """\
Le build est terminé avec le statut : ${currentBuild.currentResult}.
Consulte les logs sur Jenkins pour plus de détails.
"""
    }
  }
}
