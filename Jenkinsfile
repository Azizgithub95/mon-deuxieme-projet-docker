pipeline {
  agent any

  environment {
    DOCKERHUB_REPO = "aziztesteur95100/mon-deuxieme-projet-docker"
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build') {
      steps {
        script {
          // build :<build_number>
          docker.build("${DOCKERHUB_REPO}:${env.BUILD_NUMBER}")
        }
      }
    }

    stage('Push') {
      steps {
        script {
          // se logue avec 'docker-hub-creds'
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
    success {
      echo "✅ Image encore poussée : ${DOCKERHUB_REPO}:${env.BUILD_NUMBER} et latest"
    }
    failure {
      echo "❌ Échec du pipeline."
    }
  }
}
