pipeline {
  agent any

  // Si tu as installé un JDK et NodeJS dans Jenkins (via Global Tool Configuration),
  // adapte ici le nom de la config NodeJS (ex. "NodeJS 18").
  tools {
    nodejs 'NodeJS 18'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Install dependencies') {
      steps {
        // Installe tout une fois pour Cypress + Newman
        sh 'npm ci --no-audit --progress=false'
      }
    }

    stage('Cypress') {
      steps {
        // Lance Cypress **sans** Docker
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
        // Installe Newman globalement si besoin
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
        // Monte ton workspace dans un container k6 juste pour exécuter le test
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
          docker.withRegistry('https://mon-registry.example.com', 'docker-credentials-id') {
            def img = docker.build("mon-image:${env.BUILD_NUMBER}")
            img.push('latest')
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
