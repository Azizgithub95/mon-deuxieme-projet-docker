pipeline {
  agent any

  environment {
    // ton repository Docker Hub
    DOCKERHUB_REPO = "azizgithub95/mon-deuxieme-projet-docker"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Docker image') {
      steps {
        script {
          // on build l'image taggée par le numéro de build
          docker.build("${DOCKERHUB_REPO}:${env.BUILD_NUMBER}")
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          // on se logue sur Docker Hub avec ton credential ID
          docker.withRegistry("https://registry.hub.docker.com", "docker-hub-creds") {
            def img = docker.image("${DOCKERHUB_REPO}:${env.BUILD_NUMBER}")
            img.push()            // push <build_number>
            img.push("latest")    // push latest
          }
        }
      }
    }
  }

  post {
    success {
      echo "🎉 Image ${DOCKERHUB_REPO}:${env.BUILD_NUMBER} et :latest poussées avec succès"
    }
    failure {
      echo "❌ Échec du pipeline."
    }
  }
}
