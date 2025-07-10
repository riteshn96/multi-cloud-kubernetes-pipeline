pipeline {
    // This top-level agent is now just a lightweight coordinator
    agent any

    environment {
        DOCKER_IMAGE_NAME = "ghcr.io/riteshn96/multi-cloud-devops-pipeline"
        AWS_REGION        = "us-east-1"      // Your EKS region
        EKS_CLUSTER_NAME  = "my-app-cluster" // Your EKS cluster name
        // Make sure these match your terraform/azure.tf file
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
                    // Use the credential ID you created for GHCR
                    docker.withRegistry('https://ghcr.io', 'ghcr-credentials') {
                        def customImage = docker.build(imageTag)
                        customImage.push()
                        echo "Successfully built and pushed image: ${imageTag}"
                    }
                }
            }
        }

        // New Parent Stage for parallel deployments
        stage('Deploy to Cloud Providers') {
            // This 'parallel' block runs the stages inside it at the same time
            parallel {
                
                // --- STAGE 1: AWS Deployment ---
                stage('Deploy to AWS EKS') {
                    agent {
                        docker { image: 'alpine/k8s:1.27.5' }
                    }
                    steps {
                        // Use the AWS credentials you stored in Jenkins
                        withCredentials([aws(credentialsId: 'aws-credentials')]) {
                            script {
                                def imageTag = env.GIT_COMMIT.take(7)
                                echo "Deploying image with tag: ${imageTag} to EKS..."
                                
                                sh "export AWS_DEFAULT_REGION=${AWS_REGION}"
                                sh "aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME} --region ${AWS_REGION}"
                                
                                // Point kustomize to the AWS overlay and set the image
                                sh "kustomize edit set image ghcr.io/riteshn96/multi-cloud-devops-pipeline=ghcr.io/riteshn96/multi-cloud-devops-pipeline:${imageTag} kubernetes/overlays/aws"
                                
                                // Build and apply the manifests from the AWS overlay
                                sh "kustomize build kubernetes/overlays/aws | kubectl apply -f -"
                                
                                echo "Deployment to EKS successful!"
                            }
                        }
                    }
                }

                // --- STAGE 2: AZURE Deployment ---
                stage('Deploy to Azure AKS') {
                    agent {
                        docker { image: 'alpine/k8s:1.27.5' }
                    }
                    steps {
                        // Use the Azure Service Principal credentials you stored in Jenkins
                        withCredentials([azureServicePrincipal(credentialsId: 'azure-credentials')]) {
                            script {
                                def imageTag = env.GIT_COMMIT.take(7)
                                echo "Deploying image with tag: ${imageTag} to AKS..."
                                
                                // Install Azure CLI in the temporary agent container
                                sh 'apk add --no-cache curl'
                                sh 'curl -sL https://aka.ms/InstallAzureCLIDeb | bash'
                                
                                // Login to Azure using the Service Principal credentials from Jenkins
                                sh '/usr/bin/az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID'
                                
                                // Connect kubectl to your AKS cluster
                                sh "/usr/bin/az aks get-credentials --resource-group ${AZURE_RG_NAME} --name ${AZURE_AKS_NAME} --overwrite-existing"
                                
                                // Point kustomize to the AZURE overlay and set the image
                                sh "kustomize edit set image ghcr.io/riteshn96/multi-cloud-devops-pipeline=ghcr.io/riteshn96/multi-cloud-devops-pipeline:${imageTag} kubernetes/overlays/azure"
                                
                                // Build and apply the manifests from the AZURE overlay
                                sh "kustomize build kubernetes/overlays/azure | kubectl apply -f -"

                                echo "Deployment to AKS successful!"
                            }
                        }
                    }
                }
            } // End of parallel block
        } // End of 'Deploy to Cloud Providers' stage
    } // End of 'stages' block
} // End of 'pipeline' block