pipeline {
  agent any

  environment {
    DOCKERHUB_REPO = "azizgithub95/mon-deuxieme-projet-docker"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build') {
      steps {
        script {
          // build l'image et la tague avec le numéro de build
          docker.build("${DOCKERHUB_REPO}:${env.BUILD_NUMBER}")
        }
      }
    }

    stage('Push to Docker Hub') {
      steps {
        script {
          // '' => Docker Hub par défaut, 'docker-hub-creds' = ID de tes credentials Jenkins
          docker.withRegistry('', 'docker-hub-creds') {
            def img = docker.image("${DOCKERHUB_REPO}:${env.BUILD_NUMBER}")
            img.push()           // pousse :<build_number>
            img.push('latest')   // pousse :latest
          }
        }
      }
    }
  }

  post {
    success { echo "✅ pushed ${DOCKERHUB_REPO}:${env.BUILD_NUMBER} & latest" }
    failure { echo "❌ Pipeline failed." }
  }
}
