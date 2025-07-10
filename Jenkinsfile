pipeline {
    agent any // A lightweight coordinator

    environment {
        DOCKER_IMAGE_NAME = "ghcr.io/riteshn96/multi-cloud-devops-pipeline"
        AWS_REGION        = "us-east-1"
        EKS_CLUSTER_NAME  = "my-app-cluster"
        AZURE_RG_NAME     = "my-aks-resource-group"
        AZURE_AKS_NAME    = "my-app-aks-cluster"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build & Push Docker Image') {
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

        stage('Deploy to Cloud Providers') {
            parallel {
                
                stage('Deploy to AWS EKS') {
                    // NO AGENT BLOCK HERE
                    steps {
                        // THIS IS THE CORRECTED PATTERN
                        docker.image('alpine/k8s:1.27.5').inside {
                            withCredentials([aws(credentialsId: 'aws-credentials')]) {
                                script {
                                    def imageTag = env.GIT_COMMIT.take(7)
                                    echo "Deploying image with tag: ${imageTag} to EKS..."
                                    sh "export AWS_DEFAULT_REGION=${AWS_REGION}"
                                    sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}"
                                    sh "kustomize edit set image ghcr.io/riteshn96/multi-cloud-devops-pipeline=ghcr.io/riteshn96/multi-cloud-devops-pipeline:${imageTag} kubernetes/overlays/aws"
                                    sh "kustomize build kubernetes/overlays/aws | kubectl apply -f -"
                                    echo "Deployment to EKS successful!"
                                }
                            }
                        }
                    }
                }

                stage('Deploy to Azure AKS') {
                    // NO AGENT BLOCK HERE
                    steps {
                        // THIS IS THE CORRECTED PATTERN
                        docker.image('alpine/k8s:1.27.5').inside {
                            withCredentials([azureServicePrincipal(credentialsId: 'azure-credentials')]) {
                                script {
                                    def imageTag = env.GIT_COMMIT.take(7)
                                    echo "Deploying image with tag: ${imageTag} to AKS..."
                                    sh 'apk add --no-cache curl'
                                    sh 'curl -sL https://aka.ms/InstallAzureCLIDeb | bash'
                                    sh '/usr/bin/az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID'
                                    sh "/usr/bin/az aks get-credentials --resource-group ${AZURE_RG_NAME} --name ${AZURE_AKS_NAME} --overwrite-existing"
                                    sh "kustomize edit set image ghcr.io/riteshn96/multi-cloud-devops-pipeline=ghcr.io/riteshn96/multi-cloud-devops-pipeline:${imageTag} kubernetes/overlays/azure"
                                    sh "kustomize build kubernetes/overlays/azure | kubectl apply -f -"
                                    echo "Deployment to AKS successful!"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}