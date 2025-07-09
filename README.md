# multi-cloud_devops_pipeline
End-to-end CI/CD pipeline using Terraform, Jenkins, Docker, and Kubernetes on AWS & Azure;


# Multi-Cloud DevOps Pipeline for a Containerized Application

## 1. Project Overview

This project demonstrates a complete, end-to-end CI/CD pipeline for deploying a simple Python web application to two different cloud providers: Amazon Web Services (AWS) and Microsoft Azure. The entire infrastructure is managed as code using Terraform, and the pipeline is orchestrated by Jenkins.

The primary goal is to showcase a robust, automated, and multi-cloud deployment strategy, which is a common requirement in modern, resilient systems.

---

## 2. Architecture Diagram

*(This is one of the most important sections! Create a simple diagram and upload it to your repository, then link it here. Use a free tool like [diagrams.net](https://app.diagrams.net/) or Miro.)*

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
├── app.py # The Python Flask web application
├── requirements.txt # Python dependencies for the application
├── Dockerfile # Instructions to build the application's Docker container
├── kubernetes/ # Kubernetes manifest files (to be added)
│ ├── deployment.yaml
│ └── service.yaml
├── terraform/ # Terraform code for infrastructure (to be added)
│ └── main.tf
├── Jenkinsfile # The CI/CD pipeline-as-code (to be added)
└── README.md # Project documentation (this file)


## 5. How to Run This Project

### Prerequisites

*   An AWS Account with Free Tier access
*   An Azure Account with a Free Subscription
*   A GitHub Account
*   A Docker Hub Account
*   All necessary CLIs and tools installed locally (Git, Docker, Terraform, AWS CLI, Azure CLI).

### Step-by-Step Instructions

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/YOUR_USERNAME/multi-cloud-devops-pipeline.git
    cd multi-cloud-devops-pipeline
    ```

2.  **Build and Test Locally (Optional but Recommended):**
    *   Before deploying, verify the application works locally. Replace `your-dockerhub-username` with your Docker Hub username.
    ```bash
    # Build the Docker image
    docker build -t your-dockerhub-username/multi-cloud-devops-pipeline:latest .

    # Run the container
    docker run --rm -p 8080:80 your-dockerhub-username/multi-cloud-devops-pipeline:latest
    ```
    *   Navigate to `http://localhost:8080` in a browser to see the app running. Stop the container with `Ctrl + C` in the terminal.

3.  **Push Docker Image to a Registry:**
    *   The pipeline will need access to the container image. Log in to Docker Hub and push the image you just built.
    ```bash
    docker login
    docker push your-dockerhub-username/multi-cloud-devops-pipeline:latest
    ```

4.  **Configure Cloud Credentials:**
    *   For AWS: Run `aws configure` and provide your access keys.
    *   For Azure: Run `az login` to authenticate.

5. **Provision AWS Infrastructure with Terraform:**
    *   Navigate to the `terraform/` directory: `cd terraform`
    *   Initialize Terraform. This downloads the necessary providers and modules:
        ```bash
        terraform init
        ```
    *   Apply the configuration to create the EKS cluster and VPC. This will take 15-20 minutes.
        ```bash
        terraform apply
        ```
    *   Confirm the plan by typing `yes` when prompted.

6.  **Configure `kubectl` to Connect to the EKS Cluster

*   Once `terraform apply` is complete, you first need to get the configuration command by running `terraform output`.
*   Run the output command in your terminal:
    ```bash
    aws eks --region us-east-1 update-kubeconfig --name my-app-cluster
    ```
*   This will update your local `~/.kube/config` file, adding a new context for your EKS cluster.
*   Verify the connection by listing the cluster nodes. You should see one or more nodes in the `Ready` state.
    ```bash
    kubectl get nodes
    ```
*   **Expected Output:**
    ```
    NAME                         STATUS   ROLES    AGE    VERSION
    ip-10-0-2-140.ec2.internal   Ready    <none>   112m   v1.27.16-eks-aeac579
        ```

7.  **Set up Jenkins and Run the Pipeline (To be added):**
    *   *(This section will be filled out once Jenkins is configured.)*

8.  **Verify the Cloud Deployment:**
    *   *(This section will detail how to get the Load Balancer IP from Kubernetes.)*
    

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

---

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
---

## 8. Cleanup

To avoid incurring cloud costs, remember to destroy all infrastructure after you are finished.

```bash
cd terraform/
terraform workspace select aws && terraform destroy
terraform workspace select azure && terraform destroy