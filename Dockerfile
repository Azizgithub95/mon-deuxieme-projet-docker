# Dockerfile.jenkins
FROM jenkins/jenkins:lts-jdk17

USER root

# Installe Docker CLI et le plugin compose
RUN apt-get update && \
    apt-get install -y docker.io docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# Ajoute l’utilisateur jenkins au groupe docker
RUN groupadd docker || true && \
    usermod -aG docker jenkins

USER jenkins
