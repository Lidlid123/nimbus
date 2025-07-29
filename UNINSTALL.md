# How to Uninstall and Clean Up Resources

This guide provides the steps to completely remove all the resources created by this project. You must follow these steps in order to avoid any orphaned resources.

## Step 1: Delete the Sample Application from Kubernetes

Before destroying the infrastructure, you must delete the application you deployed to the GKE cluster.

1.  **Configure `kubectl`:** First, ensure your command line can connect to the correct GKE cluster by running this command:
    ```bash
    gcloud container clusters get-credentials app-gke-cluster \
      --project project-2-467413 --region us-central1
    ```

2.  **Delete the application:** From the project's root directory, run the following command to delete the NGINX application and its associated Ingress resource:
    ```bash
    kubectl delete -f sample-app.yaml
    ```
    Wait for this command to complete successfully before proceeding to the next step.

## Step 2: Destroy the Terraform Infrastructure

After the Kubernetes application is deleted, you can proceed to destroy all the cloud infrastructure that Terraform created in both projects.

1.  **Run `terraform destroy`:** From the project's root directory, execute the following command. It will show you a plan of all the resources that will be deleted.
    ```bash
    terraform destroy -var-file=secrets.tfvars
    ```

2.  **Confirm destruction:** Terraform will ask for confirmation. Review the plan to ensure it is only deleting the resources you expect. If it looks correct, type `yes` and press Enter to proceed.

This will remove all the GCP resources (GKE cluster, Load Balancers, VPCs, etc.) that were created by this project.
