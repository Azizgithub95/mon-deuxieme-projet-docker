pipeline {
  agent any

  environment {
    // pour Cypress : cache des binaires
    CYPRESS_CACHE = "${HOME}/.cache"
    // info image Docker à pousser
    REGISTRY     = "votre-registry.example.com"
    IMAGE_NAME   = "${REGISTRY}/mon-deuxieme-projet-docker"
  }

  stages {
    stage('Tests') {
      parallel {
        stage('Cypress') {
          agent {
            docker {
              image 'cypress/included:12.17.4'
              args  "--entrypoint='' " +
                    "-v ${CYPRESS_CACHE}:/root/.cache " +
                    "-v ${WORKSPACE}:/e2e -w /e2e"
            }
          }
          steps {
            echo '--- Installing & Running Cypress tests ---'
            sh '''
              npm ci --no-audit --progress=false
              npx cypress install
              npx cypress run
            '''
          }
        }

        stage('Newman') {
          agent {
            docker {
              image 'postman/newman:alpine'
              args  "--entrypoint='' " +
                    "-v ${WORKSPACE}:${WORKSPACE} " +
                    "-w ${WORKSPACE}"
            }
          }
          steps {
            echo '--- Running Newman tests ---'
            sh '''
              mkdir -p reports/newman
              newman run collections/MOCK_AZIZ_SERVEUR.postman_collection.json \
                --reporters cli,html \
                --reporter-html-export reports/newman/newman-report.html
            '''
          }
        }

        stage('K6') {
          agent {
            docker {
              image 'grafana/k6'
              args  "--entrypoint='' " +
                    "-v ${WORKSPACE}:${WORKSPACE} " +
                    "-w ${WORKSPACE}"
            }
          }
          steps {
            echo '--- Running K6 tests ---'
            sh '''
              mkdir -p reports/k6
              k6 run tests/test_k6.js
            '''
          }
        }
      }
    }

    stage('Build & Push Docker Image') {
      when {
        branch 'main'
      }
      agent {
        docker {
          image 'docker:24-dind'
          args  '--privileged -v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      steps {
        echo '--- Building Docker image ---'
        sh "docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."

        echo '--- Pushing to registry ---'
        // il vous faut configurer vos credentials dans Jenkins (ID = 'docker-hub-creds' par exemple)
        withCredentials([usernamePassword(credentialsId: 'docker-hub-creds',
                                         usernameVariable: 'DOCKER_USER',
                                         passwordVariable: 'DOCKER_PASS')]) {
          sh """
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin ${REGISTRY}
            docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}
          """
        }
      }
    }
  }

  post {
    always {
      echo "✅ Pipeline terminée, archivage des rapports…"
      archiveArtifacts artifacts: 'reports/**/*.*', allowEmptyArchive: true
    }
    failure {
      emailext(
        subject: "❌ Échec build ${currentBuild.fullDisplayName}",
        body:    "Le build a échoué : ${env.BUILD_URL}",
        to:      'aziztesteur@hotmail.com'
      )
    }
    success {
      emailext(
        subject: "✅ Succès build ${currentBuild.fullDisplayName}",
        body:    "Le build a réussi : ${env.BUILD_URL}",
        to:      'aziztesteur@hotmail.com'
      )
    }
  }
}
