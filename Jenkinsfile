pipeline {
    agent any

    environment {
        HOME = '/root'
    }

    stages {
        stage('Cypress Tests') {
            agent {
                docker {
                    image 'cypress/included:12.17.4'
                    args '-v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.cache:/root/.cache'
                }
            }
            steps {
                echo "--- Running Cypress tests ---"
                sh 'npx cypress run || npx cypress install && npx cypress run'
            }
        }

        stage('Newman Tests') {
            agent {
                docker {
                    image 'postman/newman:alpine'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                echo "--- Running Newman tests ---"
                sh 'newman run ./collections/MOCK_AZIZ_SERVEUR.postman_collection.json --reporters cli,html --reporter-html-export ./reports/newman/newman-report.html'
            }
        }

        stage('K6 Tests') {
            agent {
                docker {
                    image 'grafana/k6'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                echo "--- Running K6 tests ---"
                sh 'k6 run ./tests/test_k6.js'
            }
        }
    }

    post {
        always {
            echo "✅ Pipeline terminé. Archivage des résultats..."
            archiveArtifacts artifacts: 'reports/**/*.*', allowEmptyArchive: true

            emailext(
                subject: "Résultat du Build: ${currentBuild.fullDisplayName}",
                body: "Le build ${currentBuild.fullDisplayName} est terminé avec le statut : ${currentBuild.result}.\nLien : ${env.BUILD_URL}",
                to: 'aziztesteur@hotmail.com'
            )
        }
    }
}
