pipeline {
  agent any

  options {
    // désactive le checkout automatique (on le fait manuellement)
    skipDefaultCheckout()
  }

  stages {
    stage('Checkout') {
      steps {
        // nettoie le workspace avant tout
        cleanWs()
        // checkout propre du repo Git
        checkout([
          $class: 'GitSCM',
          branches: [[ name: '*/main' ]],
          userRemoteConfigs: [[
            url: 'https://github.com/Azizgithub95/mon-deuxieme-projet-docker.git',
            credentialsId: 'fa8021fb-9db2-4dec-abf5-c3aca0766855'
          ]],
          extensions: [
            [$class: 'CleanBeforeCheckout']
          ]
        ])
      }
    }

    stage('Cypress Tests') {
      agent {
        docker {
          image 'cypress/included:12.17.4'
          args  '--entrypoint="" ' +
                '-v $HOME/.npm:/root/.npm ' +
                '-v $HOME/.cache:/root/.cache ' +
                '-v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      steps {
        echo '--- Running Cypress tests ---'
        sh 'npm ci --prefer-offline --no-audit --progress=false'
        sh 'npx cypress run'
      }
    }

    stage('Newman Tests') {
      agent {
        docker {
          image 'postman/newman:alpine'
          args  '--entrypoint="" ' +
                '-v $PWD:/etc/newman ' +
                '-v $HOME/.npm:/root/.npm'
        }
      }
      steps {
        echo '--- Running Newman tests ---'
        sh '''
          newman run /etc/newman/collections/MOCK_AZIZ_SERVEUR.postman_collection.json \
            --reporters cli,html \
            --reporter-html-export /etc/newman/reports/newman-report.html
        '''
      }
    }

    stage('K6 Tests') {
      agent {
        docker {
          image 'grafana/k6'
          args  '--entrypoint="" ' +
                '-v $PWD:/workspace'
        }
      }
      steps {
        echo '--- Running K6 tests ---'
        sh 'k6 run /workspace/tests/test_k6.js'
      }
    }
  }

  post {
    always {
      echo "✅ Pipeline terminé. Archivage des résultats..."
      archiveArtifacts artifacts: 'reports/**/*.*', allowEmptyArchive: true

      emailext(
        subject: "Build Result: ${currentBuild.fullDisplayName}",
        body: """
          Le build ${currentBuild.fullDisplayName} est ${currentBuild.result}
          Consultez les détails ici : ${env.BUILD_URL}
        """,
        to: 'aziztesteur@hotmail.com'
      )
    }
  }
}
