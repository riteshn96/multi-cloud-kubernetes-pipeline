pipeline {
    agent any

    environment {
        DOCKER_IMAGE_NAME = "ghcr.io/riteshn96/multi-cloud-devops-pipeline"
        AWS_REGION        = "us-east-1"
        EKS_CLUSTER_NAME  = "my-app-cluster"
        AZURE_RG_NAME     = "my-aks-resource-group"
        AZURE_AKS_NAME    = "my-app-aks-cluster"
    }

    stages {
        // ... Checkout and Build stages are correct and remain unchanged ...
        stage('Checkout Code') { /* ... */ }
        stage('Build & Push Docker Image') { /* ... */ }

        stage('Deploy to Cloud Providers') {
            parallel {
                
                // --- THIS STAGE IS ALREADY WORKING PERFECTLY ---
                stage('Deploy to AWS EKS') {
                    steps {
                        script {
                            docker.image('alpine/k8s:1.27.5').inside {
                                withCredentials([aws(credentialsId: 'aws-credentials')]) {
                                    def imageTag = env.GIT_COMMIT.take(7)
                                    sh 'apk add --no-cache aws-cli'
                                    sh "export AWS_DEFAULT_REGION=${AWS_REGION}"
                                    sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}"
                                    sh "cd kubernetes/overlays/aws && kustomize edit set image ghcr.io/riteshn96/multi-cloud-devops-pipeline:${imageTag}"
                                    sh "kustomize build kubernetes/overlays/aws | kubectl apply -f -"
                                    echo "Deployment to EKS successful!"
                                }
                            }
                        }
                    }
                }

                // --- THIS STAGE IS BEING FIXED ---
                stage('Deploy to Azure AKS') {
                    steps {
                        script {
                            docker.image('alpine/k8s:1.27.5').inside {
                                withCredentials([azureServicePrincipal(credentialsId: 'azure-credentials')]) {
                                    def imageTag = env.GIT_COMMIT.take(7)
                                    echo "Deploying image with tag: ${imageTag} to AKS..."

                                    // 1. Install necessary tools: bash and curl
                                    sh 'apk add --no-cache bash curl'

                                    // 2. Use Microsoft's official installer script
                                    sh 'curl -sL https://aka.ms/InstallAzureCLIDeb | bash'
                                    
                                    // 3. Login and connect kubectl (use the full path to the new 'az' binary)
                                    sh '/usr/bin/az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZROURE_TENANT_ID'
                                    sh "/usr/bin/az aks get-credentials --resource-group ${AZURE_RG_NAME} --name ${AZURE_AKS_NAME} --overwrite-existing"

                                    // 4. Kustomize and apply
                                    sh "cd kubernetes/overlays/azure && kustomize edit set image ghcr.io/riteshn96/multi-cloud-devops-pipeline:${imageTag}"
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