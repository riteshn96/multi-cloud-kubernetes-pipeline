# Multi-Cloud DevOps Pipeline for a Containerized Application
End-to-end CI/CD pipeline using Terraform, Jenkins, Docker, and Kubernetes on AWS & Azure;


## 1. Project Overview

  This project demonstrates a complete, end-to-end CI/CD pipeline for deploying a simple Python web application to two different cloud providers: Amazon Web Services (AWS) and Microsoft Azure. The entire infrastructure is managed as code using Terraform, and the pipeline is orchestrated by Jenkins.

 The primary goal is to showcase a robust, automated, and multi-cloud deployment strategy, which is a common requirement in modern, resilient systems.

---

## 2. Architecture Diagram

 ![Architecture Diagram](path/to/your/diagram.png)

  **Workflow:**
 1.  A developer pushes code to the GitHub repository.
 2.  A GitHub webhook triggers the Jenkins pipeline.
 3.  Jenkins checks out the code, builds a Docker image, and pushes it to Docker Hub.
 4.  The Jenkins pipeline connects to the target cloud (AWS or Azure).
 5.  Terraform provisions the necessary infrastructure (VPC, Kubernetes Cluster).
 6.  Jenkins deploys the application to the Kubernetes cluster using the manifest files.
 7.  The application is accessible to the end-user via a public Load Balancer.

---


## 3. Tech Stack & Tools

 *   **Version Control:** Git & GitHub
 *   **Containerization:** Docker
 *   **Application:** Python (Flask)
 *   **CI/CD:** Jenkins *(Anticipating)*
 *   **Infrastructure as Code (IaC):** Terraform *(Anticipating)*
 *   **Cloud Providers:** AWS, Azure *(Anticipating)*
 *   **Container Orchestration:** Kubernetes (AWS EKS & Azure AKS) *(Anticipating)*

---

## 4. Project Structure

 The repository is structured to separate concerns, making it clean and maintainable.

 .
 ├── app.py                        # The Python Flask web application
 ├── requirements.txt             # Python dependencies for the application
 ├── Dockerfile                   # Instructions to build the application's Docker container
 ├── jenkins.Dockerfile           # Custom Dockerfile for the Jenkins Controller (includes Docker CLI)
 ├── kubernetes/                  # Kubernetes manifest files (managed by Kustomize)
 │   ├── base/                    # Common Kubernetes definitions
 │   │   ├── deployment.yaml
 │   │   ├── service.yaml
 │   │   └── kustomization.yaml
 │   └── overlays/                # Environment-specific configurations
 │       ├── aws/
 │       │   ├── kustomization.yaml
 │       │   └── patch-env.yaml   # Adds CLOUD_PROVIDER=AWS
 │       └── azure/
 │           ├── kustomization.yaml
 │           └── patch-env.yaml   # Adds CLOUD_PROVIDER=Azure
 ├── terraform/                   # Terraform code for infrastructure
 │   ├── main.tf                  # Defines AWS EKS, VPC, etc. (and Azure provider)
 │   ├── azure.tf                 # Defines Azure AKS cluster
 │   └── outputs.tf               # Defines Terraform outputs (e.g., kubeconfig commands)
 ├── Jenkinsfile                  # The CI/CD pipeline-as-code
 └── README.md                    # Project documentation (this file)

---

## 5. How to Run This Project

 ### Prerequisites

      *   An AWS Account with Free Tier access
      *   An Azure Account with a Free Subscription
      *   A GitHub Account
      *   All necessary CLIs and tools installed locally (Git, **Docker Desktop/Engine**, AWS ,Azure CLI).

 ### Step-by-Step Instructions

 1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/YOUR_GITHUB_USERNAME/multi-cloud-devops-pipeline.git
    cd multi-cloud-devops-pipeline
    ```
    *(Remember to replace YOUR_GITHUB_USERNAME with your actual GitHub username)*

 2.  **Build and Test Application Locally (Optional but Recommended):**
    *   Before deploying, verify the application works locally.
    ```bash
    # Build the Docker image
    docker build -t ghcr.io/YOUR_GITHUB_USERNAME/multi-cloud-devops-pipeline:latest .

    # Run the container (sets CLOUD_PROVIDER for local testing)
    docker run --rm -p 8080:80 -e CLOUD_PROVIDER="Local" ghcr.io/YOUR_GITHUB_USERNAME/multi-cloud-devops-pipeline:latest
    ```
    *   Navigate to `http://localhost:8080` in a browser to see the app running. Stop the container with `Ctrl + C` in the terminal.

 3.  **Configure Cloud Credentials (Local CLI & Jenkins):**
    *   **Local AWS CLI:** Run `aws configure` and provide your access keys. (Used by Terraform locally).
    *   **Local Azure CLI:** Run `az login` to authenticate. (Used by Terraform locally).
    *   **Jenkins GitHub Container Registry (GHCR) Credential:**
        1.  Create a GitHub Personal Access Token (PAT) with `write:packages` scope (Settings -> Developer settings -> Personal access tokens -> Tokens (classic)). Copy the token.
        2.  In Jenkins (Manage Jenkins -> Credentials -> (global) -> Add Credentials), add a "Username with password" credential.
            *   **Username:** Your GitHub username
            *   **Password:** Your PAT
            *   **ID:** `ghcr-credentials`
    *   **Jenkins AWS Credential:**
        1.  In AWS IAM, create an IAM User with programmatic access or an IAM Role for your Jenkins instance. Grant it permissions required for EKS operations (e.g., `AmazonEKSClusterPolicy`, `AmazonEKSWorkerNodePolicy`, `AmazonEC2ContainerRegistryReadOnly`, and specific `eks:UpdateKubeconfig` permissions).
        2.  In Jenkins (Manage Jenkins -> Credentials -> (global) -> Add Credentials), add an "AWS Credentials" credential.
            *   **ID:** `aws-credentials`
            *   Provide your Access Key ID and Secret Access Key.
    *   **Jenkins Azure Credential:**
        1.  Create an Azure Service Principal (via Azure CLI: `az ad sp create-for-rbac --name "http://my-jenkins-sp" --role "Owner" --scope "/subscriptions/YOUR_SUBSCRIPTION_ID"`). Note down the `appId`, `password`, and `tenant` ID.
        2.  **Crucially:** Assign the Service Principal the **`Owner`** role on your **Resource Group** (`my-aks-resource-group`). If your Azure subscription enforces **ABAC conditions**, you will also need to select **"Allow user to assign all roles (highly privileged)"** during the role assignment. This ensures it has permission to get AKS credentials.
        3.  In Jenkins (Manage Jenkins -> Credentials -> (global) -> Add Credentials), add an "Azure Service Principal" credential.
            *   **ID:** `azure-credentials`
            *   **Client ID:** The `appId` from your Service Principal
            *   **Client Secret:** The `password` from your Service Principal
            *   **Tenant ID:** The `tenant` ID from your Service Principal

 4.  **Provision Cloud Infrastructure with Terraform:**
    *   **Navigate to `terraform/` directory:** `cd terraform`
    *   **Initialize Terraform:**
        ```bash
        terraform init
        ```
    *   **Create Terraform Workspaces (if not already done):**
        ```bash
        terraform workspace new aws  # Or select default if you were already using it for AWS
        terraform workspace new azure
        ```
    *   **Apply AWS Infrastructure (ensure you are in the `aws` workspace):**
        ```bash
        terraform workspace select aws
        terraform apply
        ```
        *   Confirm the plan by typing `yes`. This creates your AWS EKS cluster and VPC.
    *   **Apply Azure Infrastructure (ensure you are in the `azure` workspace):**
        ```bash
        terraform workspace select azure
        terraform apply
        ```
        *   Confirm the plan by typing `yes`. This creates your Azure AKS cluster and Resource Group.

 5.  **Set up Jenkins Server (Local Docker Instance):**
    *   We will run Jenkins in a custom Docker image that includes the necessary Docker CLI tools.
    *   **Create `jenkins.Dockerfile`** in the root of your project:
        ```dockerfile
        # jenkins.Dockerfile
        FROM jenkins/jenkins:lts-jdk11
        USER root
        RUN apt-get update && apt-get install -y lsb-release curl gpg
        RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        RUN apt-get update && apt-get install -y docker-ce-cli
        USER jenkins
        ```
    *   **Build your custom Jenkins image:**
        ```bash
        docker build -t my-custom-jenkins -f jenkins.Dockerfile .
        ```
    *   **Stop/Remove any old Jenkins containers/volumes:** (Only if you've run Jenkins before)
        ```bash
        docker stop jenkins-server
        docker rm jenkins-server
        docker volume rm jenkins_home
        ```
    *   **Run the custom Jenkins container:**
        ```bash
        docker run -d --name jenkins-server -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock my-custom-jenkins
        ```
    *   **Unlock Jenkins:** Wait 30-60 seconds, then get the password:
        ```bash
        docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword
        ```
        Paste this into `http://localhost:8080`.
    *   **Install Plugins:** Choose "Install suggested plugins".
    *   **Create Admin User:** Create your Jenkins admin user.

 6.  **Configure `kubectl` Locally (Optional, for manual verification):**
    *   **For EKS:** After `terraform apply` (in `aws` workspace), run `terraform output kubeconfig_command` and execute the output command. Then `kubectl get nodes`.
    *   **For AKS:** After `terraform apply` (in `azure` workspace), run `az aks get-credentials --resource-group my-aks-resource-group --name my-app-aks-cluster --overwrite-existing`. Then `kubectl get nodes`.

 7.  **Set up Jenkins Pipeline Job:**
    *   In Jenkins (http://localhost:8080), go to **Manage Jenkins** -> **Plugins** -> **Available**. Search for and install **"Docker Pipeline"** plugin.
    *   Go back to the Jenkins dashboard. Click **"New Item"**.
    *   **Item Name:** `multi-cloud-devops-pipeline`
    *   **Type:** Select `Pipeline`. Click `OK`.
    *   **Configuration:** Scroll to the "Pipeline" section.
        *   **Definition:** `Pipeline script from SCM`
        *   **SCM:** `Git`
        *   **Repository URL:** `https://github.com/YOUR_GITHUB_USERNAME/multi-cloud-devops-pipeline.git`
        *   **Branch Specifier:** `*/main`
        *   **Script Path:** `Jenkinsfile`
    *   **Save.**

 8.  **Run the Jenkins Pipeline!**
    *   On the job's page, click **"Build Now"**.
    *   Watch the **"Console Output"** of the running build. It should now proceed through all stages (Checkout, Build & Push, Deploy to AWS EKS, Deploy to Azure AKS) and end in **SUCCESS**.

 9.  **Verify the Cloud Deployments:**
    *   **AWS:** Get the Load Balancer URL from EKS: `kubectl get service my-web-app-service -n default` (look for `EXTERNAL-IP`). Open it in your browser. You should see "Hello, World! I am running on AWS!".
    *   **Azure:** Get the Load Balancer URL from AKS: First, ensure `kubectl` is configured for AKS (`az aks get-credentials ...`). Then, `kubectl get service my-web-app-service -n default`. Open it in your browser. You should see "Hello, World! I am running on Azure!".
    

---

## 6. Key DevOps Best Practices Implemented

   *(This section directly answers the "why" and shows you understand the theory behind the tools.)*

 *   **Infrastructure as Code (IaC):** All cloud infrastructure is defined declaratively using Terraform. This ensures environments are repeatable, version-controlled, and auditable, eliminating manual configuration drift.
 *   **Everything as Code:** The application code (`app.py`), its dependencies (`requirements.txt`), and the containerization recipe (`Dockerfile`) are all version-controlled in Git. This provides a single source of truth for the application. Not just infrastructure, but the CI/CD pipeline (`Jenkinsfile`) and application deployment (`kubernetes/*.yaml`) are also stored as code in the same repository.
 *   **Immutable Infrastructure:** We don't modify running containers. Instead, we build a new Docker image for every code change and deploy it. This leads to stable and predictable systems.
 *   **Multi-Stage Docker Builds:** ** The `Dockerfile` uses a multi-stage build pattern. A `builder` stage is used to install dependencies, and the final image is built from a `slim` base, copying only the necessary application code and packages. This best practice significantly reduces the final image size, which improves security (smaller attack surface) and performance (faster downloads/deploys).
 *   **Secrets Management:** Jenkins credentials store all sensitive keys (AWS, Azure, Docker Hub). No secrets are hardcoded in the repository.
 *   **Multi-Cloud Strategy:** Deploying to both AWS and Azure demonstrates a strategy for high availability and avoiding vendor lock-in.
 *   **Pinned Dependencies for Reproducible Builds:** The `requirements.txt` file specifies exact versions for packages (e.g., `Werkzeug==2.2.2`). This prevents unexpected build failures caused by upstream library updates and ensures that the Docker image is built with the same dependencies every time, leading to highly predictable and stable builds.
 *   **Declarative Application Management (Kustomize):** Instead of using brittle `sed` commands to change the image tag in our Kubernetes manifests, we use `kustomize`. This allows us to declaratively manage our application configuration. The pipeline simply tells `kustomize` the new image tag, and `kustomize` handles the generation of the final manifest. This is cleaner, less error-prone, and makes it trivial to manage different configurations for different environments (like AWS vs. Azure).

---

## 7. Troubleshooting & Gotchas

  A log of challenges faced and their solutions.

 ### Issue: `internal error` when creating a repository on Docker Hub

 *   **Symptom:** Docker Hub returned a generic "internal error" when trying to create a repository with a specific name (`multi-cloud-devops-pipeline`).
 *   **Solution:** Pivoted from Docker Hub to the **GitHub Container Registry (GHCR)**, which is more tightly integrated with the project's source code repository. This demonstrates adaptability and knowledge of alternative, robust tooling.

 ### Issue: Pushed package not visible in the GitHub repository

 *   **Symptom:** After a successful `docker push` to `ghcr.io`, the package was not visible on the main repository page.
 *   **Solution:** For the first push from a personal account, the package defaulted to **Private** visibility and was not automatically linked to the repository. The fix was to:
    1.  Navigate to my main GitHub profile's **"Packages"** tab.
    2.  Select the package and go into its **"Package settings"**.
    3.  Change the package visibility from **Private to Public**.
    4.  Use the **"Connect repository"** feature to manually link the package to this source code repository. Subsequent pushes will now update the linked package automatically.
    ### EKS Unsupported Kubernetes Version Error

 *   **Issue:** The initial `terraform apply` failed with the error `InvalidParameterException: unsupported Kubernetes version 1.22`.
 *   **Analysis:** This error indicated that AWS EKS no longer supports the creation of new clusters with Kubernetes version 1.22, which was specified in the Terraform module. Cloud providers regularly deprecate older versions for security and support reasons.
 *   **Solution:** I resolved this by updating the `cluster_version` parameter in the `terraform/main.tf` file from `"1.22"` to a currently supported version, `"1.27"`. After this one-line code change, running `terraform apply` again was successful.
 *   **Lesson Learned:** Infrastructure as Code makes resolving such issues straightforward and repeatable. It also underscores the need to consult cloud provider documentation for supported versions when defining resources.
 ### Troubleshooting Terraform Outputs

 *   **Issue:** After creating the EKS cluster, the `terraform output` command failed with `Warning: No outputs found` and subsequent attempts gave `Error: Unsupported attribute`.
 *   **Analysis:** This was a two-part problem:
    1.  The `outputs.tf` file was not created in the correct directory initially, so Terraform didn't register it.
    2.  Once the file was created, the attributes used (`module.eks.cluster_name`) were incorrect for the specific version of the `terraform-aws-modules/eks/aws` module being used.
 *   **Solution:**
    1.  I created the `outputs.tf` file in the correct `./terraform/` directory.
    2.  I used the `terraform console` command to inspect the available attributes of the `module.eks` object.
    3.  I discovered the correct attribute for the cluster's name was `module.eks.cluster_id`.
    4.  I also learned that the region could be sourced reliably using a data block: `data.aws_region.current.name`.
    5.  I updated the `outputs.tf` file with the correct values, which then allowed the `terraform apply` and `terraform output` commands to succeed.
 *   **Lesson Learned:** When using third-party Terraform modules, it's crucial to consult their documentation or use tools like `terraform console` to inspect the exact output attributes they expose, as these can change between module versions.
 ### Pods Stuck in "Pending" State on EKS

 *   **Problem:** After deploying the application with `kubectl apply`, the pods remained in a `Pending` state indefinitely.
 *   **Analysis:** I used the `kubectl describe pod <pod-name>` command to investigate. The `Events` section showed a `FailedScheduling` warning with the message: `0/1 nodes are available: 1 Too many pods`. This indicated that the issue wasn't a lack of CPU or memory, but that the worker node had hit the maximum number of pods it was allowed to run.
 *   **Root Cause:** AWS EKS imposes a hard limit on the number of pods per EC2 instance type, based on the number of available network interfaces (ENIs). The `t2.micro` instance type only supports a maximum of 4 pods. After accounting for the system pods required by EKS, there were no available slots for my application pods.
 *   **Solution:** I modified the `terraform/main.tf` file to change the worker node `instance_types` from `["t2.micro"]` to `["t2.small"]`. A `t2.small` instance supports up to 11 pods, providing sufficient capacity. After running `terraform apply` to replace the node, the pods scheduled successfully and entered the `Running` state.
 *   **Lesson Learned:** When designing a Kubernetes cluster, it's critical to consider the pod density limits for your chosen instance types, not just CPU and memory resources.
 ### Debugging `ERR_CONNECTION_TIMED_OUT` for an EKS LoadBalancer Service

 *   **Problem:** After deploying the application and service, the pods were `Running` and the service had an `EXTERNAL-IP`, but accessing the URL resulted in a connection timeout error.

 *   **Systematic Debugging Process:**
    1.  **Initial Check:** I confirmed the Security Group rule allowing traffic from the Load Balancer's SG to the Node's SG already existed, which meant the issue was more complex than a simple firewall block.
    2.  **Isolate the Problem:** To determine if the issue was internal to the cluster or with the external Load Balancer, I launched a temporary debug pod inside the cluster using `kubectl run -it --rm --image=nicolaka/netshoot debug-pod -- bash`.
    3.  **Internal Connectivity Test:** From inside the debug pod, I used `curl http://<service-cluster-ip>` to connect to the application's internal ClusterIP. The request was successful and returned the application's "Hello World" message.
    4.  **Refined Diagnosis:** This test proved that the pods, the application, the internal service, and the container network were all working correctly. The fault had to be with the communication from the AWS Load Balancer to the worker nodes.
    5.  **Identify the NodePort:** I ran `kubectl get service` and inspected the `PORT(S)` column (`80:31234/TCP`) to find the specific **NodePort** (`31234`) that EKS assigned for the service on the worker node.
    6.  **Solution:** I edited the worker node's Security Group inbound rules. Instead of a general `All traffic` rule, I created a highly specific `Custom TCP` rule to allow traffic **only on the exact NodePort (`31234`)** from the Load Balancer's Security Group as the source.

 *   **Root Cause:** The default health checks from the Application Load Balancer (ALB) created by the AWS Load Balancer Controller need to be able to reach the specific NodePort on the instances. While a general rule was present, creating a specific rule for the NodePort resolved the health check failures.

 *   **Lesson Learned:** When debugging Kubernetes networking, it's critical to isolate the problem scope. Testing connectivity from *inside* the cluster (`pod-to-service`) is the fastest way to determine if the problem is internal or external.

 * **Issue:** Jenkins: `docker: not found`, Socket `permission denied`, and `Invalid agent type "docker"`

    *   **Symptoms:** A series of cascading errors occurred when setting up the Jenkins pipeline:
    1.  `Invalid agent type "docker"`: The pipeline failed immediately, unable to parse the `agent { docker { ... } }` syntax.
    2.  `docker: not found`: The pipeline failed when trying to execute `docker pull` or `docker build`.
    3.  `permission denied ... to connect to the Docker daemon socket`: Jenkins could find the Docker socket but lacked the OS permissions to use it.

    *   **Analysis:** This was a multi-layered problem stemming from using a bare-bones Jenkins image:
    1.  The **"Docker Pipeline" plugin** was missing, which is required for Jenkins to understand the `agent { docker { ... } }` syntax.
    2.  Even with the plugin, the main Jenkins controller container (`jenkins/jenkins:lts-jdk11`) does not have the Docker CLI installed, so it cannot execute commands like `docker pull` to start the agent.
    3.  Even with the CLI installed, the `jenkins` user inside the container does not belong to the `docker` group, so it cannot access the Docker socket mounted from the host.

    *   **Solution:** A robust, modern Jenkins-as-Code solution was implemented:
    1.  The **"Docker Pipeline"** plugin was installed via the Jenkins UI (`Manage Jenkins -> Plugins`).
    2.  A custom `jenkins.Dockerfile` was created to build a new Jenkins controller image. This file uses the official `lts-jdk11` image as a base and then:
        *   Installs the `docker-ce-cli` package.
        *   Creates a `docker` group and adds the `jenkins` user to it, solving the socket permissions issue permanently.
    3.  The `Jenkinsfile` was configured to use a **Docker agent** (`agent { docker { image 'docker:24.0' ... } }`), ensuring that the build steps run in a clean, predictable environment that is guaranteed to have the necessary tools.

        ### Debugging the Jenkins CD Stage to EKS

 **Problem:** The deployment stage failed with a series of different errors, including container  `ENTRYPOINT` issues, `NullPointerException` on credentials, and finally `aws: not found`.
  *   **Systematic Analysis:**
    1.  The first agent image (`bitnami/kubectl`) failed because its `ENTRYPOINT` was not designed for a CI/CD-style execution, causing it to exit immediately.
    2.  The `withCredentials` binding for AWS has a very specific syntax (`credentialsId` instead of `credentials`) which was causing a `NullPointerException`.
    3.  The final error, `aws: not found`, proved that the `bitnami/kubectl` image was insufficient as it did not include the AWS CLI.
  *   **Solution:** The problem was solved by selecting an agent image specifically designed for CI/CD workflows. We switched the agent in the deployment stage to `alpine/k8s:1.27.5`. This single image contains `kubectl`, `aws-cli`, and `kustomize`, providing a complete and stable toolset for the deployment job.
  *   **Lesson Learned:** Choosing the right agent environment for each stage of a pipeline is critical. A single, comprehensive agent image is often more reliable than trying to chain together multiple single-purpose images.
  
---

## 8. Cleanup

 To avoid incurring cloud costs, remember to destroy all infrastructure after you are finished.

 ```bash
 cd terraform/
 terraform workspace select aws && terraform destroy
 terraform workspace select azure && terraform destroy