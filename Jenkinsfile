// Jenkinsfile

pipeline {
    // Run this pipeline on any available Jenkins agent
    agent any

    // Define environment variables to be used throughout the pipeline
    environment {
        // This is your GitHub username, it's correct.
        DOCKER_IMAGE_NAME = "ghcr.io/riteshn96/multi-cloud-devops-pipeline" 
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Get the latest code from the repository this job is configured with
                checkout scm 
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Use the Git commit hash as a unique, traceable tag
                    // GIT_COMMIT is a built-in Jenkins variable
                    def imageTag = "${env.DOCKER_IMAGE_NAME}:${env.GIT_COMMIT.take(7)}"
                    
                    // Build the Docker image using the Docker plugin
                    // This is the corrected line.
                    docker.build(imageTag)

                    echo "Successfully built image: ${imageTag}"
                }
            }
        }
        
        stage('Placeholder: Push & Deploy') {
            steps {
                // We will add real steps here later
                echo "This is a placeholder for pushing the image and deploying to Kubernetes."
                echo "We will need to configure credentials first."
            }
        }
    }

    post {
        always {
            // Clean up the workspace after the pipeline finishes
            echo "Pipeline finished. Cleaning up workspace."
            cleanWs()
        }
    }
}