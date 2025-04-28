pipeline {
  agent any

  options {
    skipDefaultCheckout()
  }

  environment {
    // À adapter si besoin
    DOCKER_REGISTRY    = "docker.io"
    DOCKER_REPO        = "azizgithub95/mon-deuxieme-projet-docker"
    DOCKER_CREDENTIALS = "dockerhub-creds-id"
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
          agent {
            docker {
              image 'cypress/included:12.17.4'
              reuseNode true
              args  '--entrypoint="" ' +
                    '-v $HOME/.npm:/root/.npm ' +
                    '-v $HOME/.cache:/root/.cache ' +
                    '-v /var/run/docker.sock:/var/run/docker.sock'
            }
          }
          steps {
            echo '--- Running Cypress tests ---'
            sh 'npm install --no-audit --progress=false'
            sh 'npx cypress install'
            sh 'npx cypress run'
          }
        }

        stage('Newman') {
          agent {
            docker {
              image 'postman/newman:alpine'
              reuseNode true
              args  '--entrypoint=""'
            }
          }
          steps {
            echo '--- Running Newman tests ---'
            sh '''
              mkdir -p reports/newman
              newman run ./collections/MOCK_AZIZ_SERVEUR.postman_collection.json \
                --reporters cli,html \
                --reporter-html-export reports/newman/newman-report.html
            '''
          }
        }

        stage('K6') {
          agent {
            docker {
              image 'grafana/k6'
              reuseNode true
              args  '--entrypoint=""'
            }
          }
          steps {
            echo '--- Running K6 tests ---'
            sh '''
              mkdir -p reports/k6
              k6 run ./tests/test_k6.js
            '''
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      when { branch 'main' }
      steps {
        script {
          // build image taguée par le build number
          def img = docker.build("${DOCKER_REPO}:${env.BUILD_NUMBER}")
          // push vers le registry avec login
          docker.withRegistry("https://${DOCKER_REGISTRY}", DOCKER_CREDENTIALS) {
            img.push()
            img.push("latest")
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
        subject: "✅ Build réussi : ${currentBuild.fullDisplayName}",
        body:    "Le build s’est terminé avec succès ! Consultez ${env.BUILD_URL}",
        to:      'aziztesteur@hotmail.com'
      )
    }
    failure {
      emailext(
        subject: "🚨 Build échoué : ${currentBuild.fullDisplayName}",
        body:    "Le build a échoué. Détails : ${env.BUILD_URL}",
        to:      'aziztesteur@hotmail.com'
      )
    }
  }
}
