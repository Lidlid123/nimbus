# GCP Multi-Tier HTTPS Load Balancer with PSC & GKE Deployment Guide

This guide provides the steps to deploy the infrastructure on your two new GCP projects.

### **Phase 1: Prerequisites & Setup**

**1. Install Tools:**
   - Make sure you have the [Google Cloud SDK (`gcloud`)](https://cloud.google.com/sdk/docs/install) installed.
   - Make sure you have [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) installed.

**2. Authenticate:**
   - Log in to your GCP account. This command will open a browser window for you to authenticate.
     ```bash
     gcloud auth application-default login
     ```

**3. Enable Required APIs:**
   - You must enable the following APIs in **both** `project-1-467413` and `project-2-467413`.

     Run these commands for each project:
     ```bash
     # Set your project ID first
     gcloud config set project YOUR_PROJECT_ID_HERE

     # Then enable the APIs
     gcloud services enable compute.googleapis.com
     gcloud services enable servicenetworking.googleapis.com
     gcloud services enable container.googleapis.com
     ```
     *Note: The Cloud Armor API is part of the Compute Engine API and is enabled with it.*

### **Phase 2: Deploy Infrastructure with Terraform**

**1. Initialize Terraform:**
   - From your project's root directory (`/home/lidor/nimbus`), run this command to download the required Google Cloud provider.
     ```bash
     terraform init
     ```

**2. Create a Variables File:**
   - The plan requires a variables file. Create a file named `secrets.tfvars` in the `/home/lidor/nimbus/` directory.
   - Add the public domain you intend to use to this file. For example:
     ```terraform
     domain = "your-actual-domain.com"
     ```

**3. Plan and Apply:**
   - Run the following commands to preview and then deploy your infrastructure.
     ```bash
     # Preview the changes
     terraform plan -var-file=secrets.tfvars

     # Apply the changes to create the resources
     terraform apply -var-file=secrets.tfvars
     ```
   - Terraform will ask for confirmation before creating the resources. Type `yes` to proceed.

### **Phase 3: Deploy the Sample Application**

**1. Configure `kubectl`:**
   - Once Terraform finishes, get the credentials for your new GKE cluster. This command will configure `kubectl` to connect to it.
     ```bash
     gcloud container clusters get-credentials app-gke-cluster \
       --project project-2-467413 --region us-central1
     ```

**2. Deploy the NGINX Application:**
   - Apply the `sample-app.yaml` manifest to deploy the NGINX web server and the necessary Ingress resources.
     ```bash
     kubectl apply -f sample-app.yaml
     ```

After completing these steps, the entire environment will be set up. You can then find the external IP address of your load balancer and browse to your domain to see the sample NGINX application.
