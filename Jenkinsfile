pipeline {
  agent any
  environment {
    // Vos variables d’environnement, si besoin
    REGISTRY = 'mon-registry.example.com'
    IMAGE_NAME = 'mon-image'
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Tests (parallel)') {
      parallel {
        stage('Cypress') {
          agent {
            docker {
              image 'cypress/included:12.17.4'
              args  '--entrypoint="" -u root'
            }
          }
          steps {
            sh 'npm ci --no-audit --progress=false'
            sh 'npx cypress run --record=false'
            archiveArtifacts artifacts: 'cypress/results/**/*', allowEmptyArchive: true
          }
        }

        stage('Newman') {
          agent {
            docker {
              image 'postman/newman:alpine'
              args  '--entrypoint="" -u root'
            }
          }
          steps {
            sh 'npm ci --no-audit --progress=false'
            sh '''
              mkdir -p reports/newman
              newman run MOCK_AZIZ_SERVEUR.postman_collection.json --reporters cli
            '''
            archiveArtifacts artifacts: 'reports/newman/**/*', allowEmptyArchive: true
          }
        }

        stage('K6') {
          agent {
            docker {
              image 'grafana/k6'
              args  '--entrypoint="" -u root'
            }
          }
          steps {
            // On exécute simplement K6, sans génération de rapport
            sh 'k6 run test_k6.js'
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      when {
        // Ne build & push que si tout est OK
        expression { currentBuild.currentResult == 'SUCCESS' }
      }
      steps {
        script {
          docker.withRegistry("https://${env.REGISTRY}", 'docker-credentials-id') {
            def img = docker.build("${env.IMAGE_NAME}:${env.BUILD_NUMBER}")
            img.push('latest')
          }
        }
      }
    }
  }

  post {
    always {
      echo "🔔 Pipeline terminé avec : ${currentBuild.currentResult}"
    }
  }
}
