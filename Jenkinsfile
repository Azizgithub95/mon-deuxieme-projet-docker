pipeline {
    agent any

    stages {
        stage('Install dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Run Cypress test') {
            steps {
                sh 'npx cypress run'
            }
        }

        stage('Run Newman test') {
            steps {
                sh 'newman run MOCK_AZIZ_SERVEUR.postman_collection.json -r cli,html --reporter-html-export report_newman.html'
            }
        }

        stage('Run K6 test') {
            steps {
                sh 'k6 run test_k6.js'
            }
        }
    }

    post {
        always {
            echo '✅ Pipeline finished. Archiving of results...'
            archiveArtifacts artifacts: '**/*.html', allowEmptyArchive: true
        }
    }
}
