pipeline {
  agent any

  environment {
    CYPRESS_CACHE = "${HOME}/.cache"
    REGISTRY      = "docker.io"                       // ou ton registry privé
    IMAGE_NAME    = "${REGISTRY}/azizgithub95/mon-deuxieme-projet-docker"
  }

  stages {
    stage('Checkout') {
      steps {
        cleanWs()
        checkout scm
      }
    }

    stage('Tests') {
      parallel {
        stage('Cypress') {
          steps {
            echo '--- Cypress tests ---'
            script {
              docker.image('cypress/included:12.17.4').inside(
                "--entrypoint=\"\" " +
                "-v ${CYPRESS_CACHE}:/root/.cache " +
                "-v /var/run/docker.sock:/var/run/docker.sock"
              ) {
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
              docker.image('postman/newman:alpine').inside("--entrypoint=\"\"") {
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
              docker.image('grafana/k6').inside("--entrypoint=\"\"") {
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
      when { branch 'main' }
      steps {
        echo '--- Building & pushing Docker image ---'
        script {
          docker.withRegistry("https://${REGISTRY}", 'docker-hub-creds') {
            def img = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
            img.push()
            img.push('latest')
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'reports/**/*.*', allowEmptyArchive: true
    }
    success {
      emailext(
        subject: "✅ Succès ${currentBuild.fullDisplayName}",
        body:    "Build encore  réussi : ${env.BUILD_URL}",
        to:      'aziztesteur@hotmail.com'
      )
    }
    failure {
      emailext(
        subject: "❌ Échec ${currentBuild.fullDisplayName}",
        body:    "Build huj échoué : ${env.BUILD_URL}",
        to:      'aziztesteur@hotmail.com'
      )
    }
  }
}
