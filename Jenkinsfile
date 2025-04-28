pipeline {
  agent any

  environment {
    // Change ici pour ton namespace sur Docker Hub
    DOCKER_IMAGE = 'aziztesteur95100/mon-deuxieme-projet-docker'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Tests en parallèle') {
      parallel {
        stage('Cypress') {
          agent {
            docker {
              image 'cypress/included:12.17.4'
              // si besoin de root : args '-u root'
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

        stage('k6') {
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
          // 'docker-hub-creds' doit être un "Username with password" créé dans Jenkins > Credentials
          docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-creds') {
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
      archiveArtifacts artifacts: 'reports/**/*.*, Jenkinsfile', fingerprint: true
    }
    success {
      echo '✅ Tout s’est bien passé !'
    }
    failure {
      echo '❌ Échec de la pipeline.'
    }
  }
}
