pipeline {
  agent any

  tools {
    nodejs 'NodeJS 18'
  }

  environment {
    // Remplace par ton registry et tes credentials
    DOCKER_REGISTRY = 'https://mon-registry.example.com'
    DOCKER_CREDENTIALS_ID = 'docker-credentials-id'
    IMAGE_NAME = "mon-image"
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
        sh 'npx cypress run --record=false'
      }
      post {
        always {
          archiveArtifacts artifacts: 'cypress/results/**/*', allowEmptyArchive: true
        }
      }
    }

    stage('Newman') {
      steps {
        sh 'npm install -g newman'
        sh '''
          mkdir -p reports/newman
          newman run MOCK_AZIZ_SERVEUR.postman_collection.json --reporters cli
        '''
      }
      post {
        always {
          archiveArtifacts artifacts: 'reports/newman/**/*', allowEmptyArchive: true
        }
      }
    }

    stage('K6') {
      steps {
        // Exécution de K6 dans son container, pas de rapport HTML
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
          docker.withRegistry(env.DOCKER_REGISTRY, env.DOCKER_CREDENTIALS_ID) {
            def img = docker.build("${env.IMAGE_NAME}:${env.BUILD_NUMBER}")
            img.push('latest')
          }
        }
      }
    }
  }

  post {
    always {
      echo "🔔 Pipeline encore terminé avec le statut : ${currentBuild.currentResult}"
    }
  }
}
