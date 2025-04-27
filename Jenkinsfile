pipeline {
    agent any

    environment {
        CACHE_DIR = "$HOME/.cache"
    }

    stages {
        stage('Cypress Tests') {
            agent {
                docker {
                    image 'cypress/included:12.17.4'
                    args "-v $CACHE_DIR:/root/.cache"
                }
            }
            steps {
                echo "--- Running Cypress tests ---"
                sh 'npx cypress run'
            }
        }

        stage('Newman Tests') {
            agent {
                docker {
                    image 'postman/newman:alpine'
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
                subject: "Build Result: ${currentBuild.fullDisplayName}",
                body: "Le build ${currentBuild.fullDisplayName} est terminé avec le statut : ${currentBuild.result}\nConsultez les détails ici : ${env.BUILD_URL}",
                to: 'aziztesteur@hotmail.com'
            )
        }
    }
}
