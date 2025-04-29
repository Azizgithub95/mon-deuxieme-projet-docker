node {
  // 1) Checkout unique
  stage('Checkout') {
    checkout scm
  }

  // 2) Pré-charge des images Docker
  def imgCypress = docker.image('cypress/included:12.17.4')
  def imgNewman  = docker.image('postman/newman:alpine')
  def imgK6      = docker.image('grafana/k6')

  // 3) Exécution parallèle des tests
  stage('Tests (parallel)') {
    parallel(
      Cypress: {
        imgCypress.inside('--entrypoint="" -u root') {
          sh 'npm ci --no-audit --progress=false'
          sh 'npx cypress run --record=false'
        }
        archiveArtifacts artifacts: 'cypress/**/*', allowEmptyArchive: true
      },

      Newman: {
        imgNewman.inside('--entrypoint="" -u root') {
          sh 'npm ci --no-audit --progress=false'
          sh '''
            mkdir -p reports/newman
            newman run MOCK_AZIZ_SERVEUR.postman_collection.json --reporters cli
          '''
        }
        archiveArtifacts artifacts: 'reports/newman/**/*.html', allowEmptyArchive: true
      },

      K6: {
        // Pas d'installation, on se contente de lancer k6
        imgK6.inside('--entrypoint="" -u root') {
          sh 'k6 run test_k6.js'
        }
      }
    )
  }

  // 4) Build & push seulement si tout a réussi
  stage('Build & Push Docker Image') {
    when {
      expression { currentBuild.result == null || currentBuild.result == 'SUCCESS' }
    }
    steps {
      script {
        docker.build("mon-image:${env.BUILD_NUMBER}")
              .push('latest')
      }
    }
  }

  // 5) Toujours notifier à la fin
  stage('Final') {
    echo "🔔 Pipeline terminé avec : ${currentBuild.currentResult ?: 'SUCCESS'}"
  }
}
