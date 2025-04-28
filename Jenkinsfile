stage('Tests') {
  parallel {
    stage('Cypress') {
      steps {
        echo '--- Cypress tests ---'
        script {
          docker.image('cypress/included:12.17.4').inside {
            sh '''
              npm ci --no-audit --progress=false
              npx cypress install
              npx cypress run
            '''
          }
        }
      }
    }

    stage('Newman') {
      steps {
        echo '--- Newman tests ---'
        script {
          docker.image('postman/newman:alpine').inside('--entrypoint=""') {
            sh '''
              npm ci --no-audit --progress=false || true
              mkdir -p reports/newman
              newman run MOCK_AZIZ_SERVEUR.postman_collection.json \
                --reporters cli,html \
                --reporter-html-export reports/newman/newman-report.html
            '''
          }
        }
      }
    }

    stage('K6') {
      steps {
        echo '--- K6 tests ---'
        script {
          docker.image('grafana/k6').inside {
            sh '''
              mkdir -p reports/k6
              k6 run test_k6.js
            '''
          }
        }
      }
    }
  }
}
