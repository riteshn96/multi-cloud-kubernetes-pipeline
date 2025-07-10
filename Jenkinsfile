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
        // --- Full Checkout Code Stage ---
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        // --- Full Build & Push Stage ---
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

                stage('Deploy to Azure AKS') {
                    steps {
                        script {
                            docker.image('alpine/k8s:1.27.5').inside {
                                withCredentials([azureServicePrincipal(credentialsId: 'azure-credentials')]) {
                                    def imageTag = env.GIT_COMMIT.take(7)
                                    echo "Deploying image with tag: ${imageTag} to AKS..."

                                    // 1. Install Alpine prerequisites, now including python3-dev
                                    sh 'apk add --no-cache python3 py3-pip py3-setuptools py3-wheel py3-cffi libffi-dev openssl-dev build-base python3-dev'

                                    // 2. Install the Azure CLI using pip
                                    sh 'pip install azure-cli'

                                    // 3. Login and connect kubectl
                                    sh 'az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID'
                                    sh "az aks get-credentials --admin --resource-group ${AZURE_RG_NAME} --name ${AZURE_AKS_NAME} --overwrite-existing"

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