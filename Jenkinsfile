pipeline {
  agent any

  options {
    // nettoie le workspace avant chaque build
    cleanWs()
    // empêche le checkout automatique en début
    skipDefaultCheckout(true)
  }

  stages {
    stage('Checkout') {
      steps {
        // clean + checkout propre
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
          args  '-v $HOME/.cache:/root/.cache ' +
                '-v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      steps {
        echo '--- Running Cypress tests ---'
        sh 'npm ci'
        sh 'npx cypress run'
      }
    }

    stage('Newman Tests') {
      agent {
        docker {
          image 'postman/newman:alpine'
          // Monte tout le workspace pour accéder aux collections et aux reports
          args '-v $PWD:/etc/newman'
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
          args  '-v $PWD:/workspace'
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
