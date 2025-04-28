pipeline {
  agent any

  environment {
    // À adapter
    REGISTRY_URL          = 'https://index.docker.io/v1/'
    REGISTRY_CREDENTIALS  = 'docker-hub-credentials-id'
    IMAGE_NAME            = 'azizgithub95/mon-deuxieme-projet-docker'
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
          agent {
            docker {
              image 'cypress/included:12.17.4'
              args  '--entrypoint=""'
            }
          }
          steps {
            sh 'npm ci --no-audit --progress=false'
            sh 'npx cypress run'
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
            sh 'npm ci --no-audit --progress=false'
            sh '''
              mkdir -p reports/newman
              newman run MOCK_AZIZ_SERVEUR.postman_collection.json \
                --reporters cli,html \
                --reporter-html-export reports/newman/newman-report.html
            '''
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
            sh '''
              mkdir -p reports/k6
              k6 run test_k6.js
            '''
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      when {
        expression { currentBuild.currentResult == 'SUCCESS' }
      }
      steps {
        script {
          docker.withRegistry(REGISTRY_URL, REGISTRY_CREDENTIALS) {
            def img = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
            img.push()
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'reports/**/*', allowEmptyArchive: true
    }
    failure {
      emailext (
        to:      'aziztesteur@hotmail.com',
        subject: "Échec du build ${env.JOB_NAME} #${env.BUILD_NUMBER}",
        body:    "Le build a échoué. Consulte les logs Jenkins pour plus de détails."
      )
    }
  }
}
