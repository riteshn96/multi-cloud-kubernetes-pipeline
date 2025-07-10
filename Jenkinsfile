// Jenkinsfile with Deploy Stage

pipeline {
    // This top-level agent is now just a lightweight coordinator
    agent any

    environment {
        DOCKER_IMAGE_NAME = "ghcr.io/riteshn96/multi-cloud-devops-pipeline"
        AWS_REGION        = "us-east-1"      // Your EKS region
        EKS_CLUSTER_NAME  = "my-app-cluster" // Your EKS cluster name
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push Docker Image') {
            // Use a specific agent for this stage
            agent {
                docker { 
                    image 'docker:24.0'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                script {
                    def imageTag = "${env.DOCKER_IMAGE_NAME}:${env.GIT_COMMIT.take(7)}"
                    docker.withRegistry('https://ghcr.io', 'ghcr-credentials') {
                        def customImage = docker.build(imageTag)
                        customImage.push()
                        echo "Successfully built and pushed image: ${imageTag}"
                    }
                }
            }
        }

        stage('Deploy to AWS EKS') {
    // Use a different agent that has all our deployment tools
    agent {
        docker {
            image 'bitnami/kubectl:1.27'
            // Add this args line to override the container's default entrypoint
            args '--entrypoint=""' 
        }
    }
    steps {
        // Correct the syntax for withCredentials
        withCredentials([aws(credentialsId: 'aws-credentials', region: env.AWS_REGION)]) {
            script {
                def imageTag = env.GIT_COMMIT.take(7)
                
                echo "Deploying image with tag: ${imageTag} to EKS cluster: ${EKS_CLUSTER_NAME}"
                
                // 1. Configure kubectl to connect to the EKS cluster
                sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME}"
                
                // 2. Use kustomize to set the new image tag in the deployment manifest
                sh "cd kubernetes && kustomize edit set image ghcr.io/riteshn96/multi-cloud-devops-pipeline=ghcr.io/riteshn96/multi-cloud-devops-pipeline:${imageTag}"
                
                // 3. Apply the updated manifests to the cluster
                sh "kustomize build kubernetes/ | kubectl apply -f -"
                
                echo "Deployment to EKS successful!"
            }
        }
    }
}
    }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}