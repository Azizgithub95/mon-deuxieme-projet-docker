# Dockerfile
FROM alpine:latest

# (optionnel) copie un fichier ou un script, sinon on se contente d'un echo
# COPY . /app
# WORKDIR /app

CMD ["echo", "Hello from my first Docker image!"]
