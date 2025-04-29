pipeline {
  agent any

  environment {
    IMAGE_NAME         = 'aziztesteur95100/mon-deuxieme-projet'
    DOCKER_CREDENTIALS = 'docker-hub-credentials'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Cypress tests') {
      agent {
        docker {
          image 'cypress/included:12.17.4'
          // override ENTRYPOINT pour exécuter directement nos commandes
          args  '--entrypoint="" --user root:root'
        }
      }
      steps {
        sh '''
          npm ci --no-audit --progress=false
          npx cypress run --record=false
        '''
      }
      post {
        always {
          archiveArtifacts artifacts: 'cypress/videos/**/*.mp4', allowEmptyArchive: true
        }
      }
    }

    stage('Newman tests') {
      agent {
        docker {
          image 'postman/newman:alpine'
          args  '--entrypoint=""'
        }
      }
      steps {
        sh '''
          npm install -g newman-reporter-html
          mkdir -p reports/newman
          newman run MOCK_AZIZ_SERVEUR.postman_collection.json \
            --reporters cli,html \
            --reporter-html-export reports/newman/newman-report.html
        '''
      }
      post {
        always {
          archiveArtifacts artifacts: 'reports/newman/*.html', allowEmptyArchive: true
        }
      }
    }

    stage('K6 tests') {
      agent {
        docker {
          image 'grafana/k6'
        }
      }
      steps {
        sh '''
          mkdir -p reports/k6
          k6 run test_k6.js --out json=reports/k6/summary.json
        '''
      }
      post {
        always {
          archiveArtifacts artifacts: 'reports/k6/*.json', allowEmptyArchive: true
        }
      }
    }

    stage('Build & Push Docker Image') {
      when {
        expression { currentBuild.currentResult == 'SUCCESS' }
      }
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
      mail to: 'aziz.aidel@hotmail.fr',
           subject: "Build ${currentBuild.fullDisplayName} – ${currentBuild.currentResult}",
           body: "Le build Jenkins s'est terminé avec le statut : ${currentBuild.currentResult}."
    }
  }
}
