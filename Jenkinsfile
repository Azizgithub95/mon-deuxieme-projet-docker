pipeline {
  agent any

  options { skipDefaultCheckout() }

  environment {
    DOCKER_REGISTRY     = "docker.io"
    DOCKER_REPO         = "azizgithub95/mon-deuxieme-projet-docker"
    DOCKER_CREDENTIALS  = "dockerhub-creds-id"
  }

  stages {
    stage('Checkout') {
      steps {
        cleanWs()
        checkout scm
      }
    }

    stage('Tests') {
      parallel {
        stage('Cypress') { /* …comme montré plus haut…*/ }
        stage('Newman')  { /* …*/ }
        stage('K6')      { /* …*/ }
      }
    }

    stage('Build & Push Docker Image') {
      when { branch 'main' }
      steps {
        script {
          def img = docker.build("${DOCKER_REPO}:${env.BUILD_NUMBER}")
          docker.withRegistry("https://${DOCKER_REGISTRY}", DOCKER_CREDENTIALS) {
            img.push()
            img.push("latest")
          }
        }
      }
    }
  }

  post {
    always {
      archiveArtifacts artifacts: 'reports/**/*.*', allowEmptyArchive: true
    }
    success {
      emailext subject: "✅ encore Succès : ${currentBuild.fullDisplayName}",
               body: "Build OK ! ${env.BUILD_URL}",
               to: 'aziztesteur@hotmail.com'
    }
    failure {
      emailext subject: "🚨 Échec : ${currentBuild.fullDisplayName}",
               body: "Build FAIL. ${env.BUILD_URL}",
               to: 'aziztesteur@hotmail.com'
    }
  }
}
