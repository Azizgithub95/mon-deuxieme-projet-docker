pipeline {
    agent any

    environment {
        CACHE_VOLUME = "$HOME/.cache:/root/.cache"
    }

    stages {
        stage('Cypress Tests') {
            steps {
                echo "--- Running Cypress tests ---"
                sh '''
                    docker run --rm -v $(pwd):/e2e -w /e2e -v $HOME/.cache:/root/.cache cypress/included:12.17.4 npx cypress run
                '''
            }
        }

        stage('Newman Tests') {
            steps {
                echo "--- Running Newman tests ---"
                sh '''
                    docker run --rm -v $(pwd):/etc/newman -w /etc/newman postman/newman:alpine \
                    run ./collections/MOCK_AZIZ_SERVEUR.postman_collection.json --reporters cli,html \
                    --reporter-html-export ./reports/newman/newman-report.html
                '''
            }
        }

        stage('K6 Tests') {
            steps {
                echo "--- Running K6 tests ---"
                sh '''
                    docker run --rm -v $(pwd):/scripts -w /scripts grafana/k6 run ./tests/test_k6.js
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
