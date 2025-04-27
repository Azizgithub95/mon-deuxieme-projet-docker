pipeline {
  agent any

  options {
    skipDefaultCheckout()
  }

  stages {
    stage('Checkout') {
      steps {
        cleanWs()
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
          reuseNode true
          args  '--entrypoint="" ' +
                '-v $HOME/.npm:/root/.npm ' +
                '-v $HOME/.cache:/root/.cache ' +
                '-v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      steps {
        echo '--- Installing & Running Cypress tests ---'
        sh 'npm install --no-audit --progress=false'
        sh 'npx cypress install'
        sh 'npx cypress run'
      }
    }

    stage('Newman Tests') {
      agent {
        docker {
          image 'postman/newman:alpine'
          reuseNode true
          args  '--entrypoint="" ' +
                '-v $HOME/.npm:/root/.npm'
        }
      }
      steps {
        echo '--- Running Newman tests ---'
        sh '''
          mkdir -p reports/newman
          newman run ./MOCK_AZIZ_SERVEUR.postman_collection.json \
            --reporters cli,html \
            --reporter-html-export reports/newman/newman-report.html
        '''
      }
    }

    stage('K6 Tests') {
      agent {
        docker {
          image 'grafana/k6'
          reuseNode true
          args  '--entrypoint=""'
        }
      }
      steps {
        echo '--- Running K6 tests ---'
        sh '''
          mkdir -p reports/k6
          k6 run test_k6.js
        '''
      }
    }
  }

  post {
    always {
      echo "✅ Pipeline terminé. Archivage des résultats..."
      archiveArtifacts artifacts: 'reports/**/*.*', allowEmptyArchive: true
    }

    success {
      echo "🎉 Build réussi ! Envoi du mail de notification (SUCCESS)."
      emailext(
        subject: "✅ Succès : ${currentBuild.fullDisplayName}",
        body: """
          Bravo ! Le build ${currentBuild.fullDisplayName} s'est terminé avec succès.
          Consultez les détails ici : ${env.BUILD_URL}
        """,
        to: 'aziztesteur@hotmail.com'
      )
    }

    failure {
      echo "❌ Build échoué ! Envoi du mail de notification (FAILURE)."
      emailext(
        subject: "🚨 Échec : ${currentBuild.fullDisplayName}",
        body: """
          Oups, le build ${currentBuild.fullDisplayName} a échoué avec l’état : ${currentBuild.result}.
          Consultez les logs ici : ${env.BUILD_URL}
        """,
        to: 'aziztesteur@hotmail.com'
      )
    }
  }
}
