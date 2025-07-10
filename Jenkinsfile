// Jenkinsfile - Final Version with Docker Agent

pipeline {
    // Tell Jenkins to run all stages inside a Docker container
    // This container has the 'docker' command available
    agent {
        docker { 
            image 'docker:24.0' // Use a specific, stable version of the official Docker image
            args '-v /var/run/docker.sock:/var/run/docker.sock' // Mount the socket into THIS container too
        }
    }

    environment {
        DOCKER_IMAGE_NAME = "ghcr.io/riteshn96/multi-cloud-devops-pipeline"
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Now we need to check out the code from the real repository
                checkout scm
            }
        }

        stage('Build & Push Docker Image') {
    steps {
        script {
            def imageTag = "${env.DOCKER_IMAGE_NAME}:${env.GIT_COMMIT.take(7)}"
            
            // This block will log in to GHCR using the credentials we just added
            docker.withRegistry('https://ghcr.io', 'ghcr-credentials') {
                
                // Build the image
                def customImage = docker.build(imageTag)
                
                // Push the image to the registry
                customImage.push()
                
                echo "Successfully built and pushed image: ${imageTag}"
            }
        }
    }
}