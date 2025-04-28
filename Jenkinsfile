pipeline {
  agent any

  environment {
    // Nom de ton image Docker sur Docker Hub
    DOCKER_IMAGE = 'aziztesteur95100/mon-deuxieme-projet-docker'
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
          // Pour lancer Cypress dans un container
          agent {
            docker {
              image 'cypress/included:12.17.4'
              args  '-u root' 
            }
          }
          steps {
            sh 'npm ci --no-audit --progress=false'
            sh 'npx cypress run'
          }
        }

        stage('Newman') {
          // Pour lancer Newman dans un container
          agent {
            docker {
              image 'postman/newman:alpine'
            }
          }
          steps {
            sh 'npm ci --no-audit --progress=false'
            sh 'mkdir -p reports/newman'
            sh '''
              newman run MOCK_AZIZ_SERVEUR.postman_collection.json \
                --reporters cli,html \
                --reporter-html-export reports/newman/newman-report.html
            '''
          }
        }

        stage('K6') {
          // Pour lancer K6 dans un container
          agent {
            docker {
              image 'grafana/k6'
            }
          }
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
          // Se connecter à Docker Hub avec l'ID 'docker-hub-creds'
          docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-creds') {
            // Construire l'image et la tagger avec le numéro de build + latest
            def img = docker.build("${DOCKER_IMAGE}:${env.BUILD_NUMBER}")
            img.push("${env.BUILD_NUMBER}")
            img.push('latest')
          }
        }
      }
    }
  }

  post {
    always {
      // Archive tes rapports et le Jenkinsfile pour debug
      archiveArtifacts artifacts: 'reports/**/*.*, Jenkinsfile', fingerprint: true
    }
    success {
      echo '✅ Build et push Docker réussis !'
    }
    failure {
      echo '❌ Quelque chose s’est mal passé…'
    }
  }
}
