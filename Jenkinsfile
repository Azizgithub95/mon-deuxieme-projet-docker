pipeline {
    agent any

    options {
        skipDefaultCheckout true  // << NE PAS refaire un checkout car Jenkins l'a déjà fait
    }

    environment {
        WORKSPACE_DIR = "${env.WORKSPACE}"
        CACHE_DIR = "${env.HOME}/.cache"
    }

    stages {
        stage('Cypress Tests') {
            steps {
                echo "--- Running Cypress tests ---"
                sh '''
                    docker run --rm \
                        -v "$WORKSPACE_DIR":/e2e \
                        -w /e2e \
                        
                        cypress/included:12.17.4 npx cypress run
                '''
            }
        }

        stage('Newman Tests') {
            steps {
                echo "--- Running Newman tests ---"
                sh '''
                    docker run --rm \
                        -v "$WORKSPACE_DIR":/etc/newman \
                        postman/newman:latest run /etc/newman/collections/MOCK_AZIZ_SERVEUR.postman_collection.json \
                        --reporters cli,html --reporter-html-export /etc/newman/reports/newman/newman-report.html
                '''
            }
        }

        stage('K6 Tests') {
            steps {
                echo "--- Running K6 tests ---"
                sh '''
                    docker run --rm \
                        -v "$WORKSPACE_DIR":/k6 \
                        grafana/k6 run /k6/tests/test_k6.js
                '''
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
