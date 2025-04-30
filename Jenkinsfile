pipeline {
  agent any

  tools {
    nodejs 'NodeJS 18'
  }

  environment {
    REGISTRY      = "mon-registry"
    IMAGE_NAME    = "mon-deuxieme-projet-docker"
    VERSION       = "v1.0"
    LATEST        = "latest"
    CREDENTIALS   = "docker-credentials-id"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install dependencies') {
      steps {
        sh 'npm ci --no-audit --progress=false'
      }
    }

    stage('Cypress') {
      steps {
        sh 'npx cypress install'
        sh 'npx cypress run --record=false'
      }
      post {
        always {
          archiveArtifacts artifacts: 'cypress/videos/**,cypress/screenshots/**', allowEmptyArchive: true
        }
      }
    }

    stage('Newman') {
      steps {
        sh 'npm install -g newman newman-reporter-html'
        sh '''
          mkdir -p reports/newman
          newman run MOCK_AZIZ_SERVEUR.postman_collection.json \
            --reporters cli,html \
            --reporter-html-export reports/newman/newman-report.html
        '''
      }
      post {
        always {
          archiveArtifacts artifacts: 'reports/newman/**/*.html', allowEmptyArchive: true
        }
      }
    }

    stage('K6') {
      steps {
        // lance juste le test K6, sans rapport ni Grafana
        sh '''
          docker run --rm \
            -v "$PWD":/scripts \
            -w /scripts \
            grafana/k6 \
            run test_k6.js
        '''
      }
    }

    stage('Build & Push Docker Image') {
      when {
        expression { currentBuild.currentResult == 'SUCCESS' }
      }
      steps {
        script {
          def img = docker.build("${REGISTRY}/${IMAGE_NAME}:${VERSION}")
          docker.withRegistry("https://${REGISTRY}", "${CREDENTIALS}") {
            img.push()
            img.push(LATEST)
          }
        }
      }
    }
  }

  post {
    always {
      echo "🔔 Pipeline terminé avec le statut : ${currentBuild.currentResult}"
    }
  }
}
