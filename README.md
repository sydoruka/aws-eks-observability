This project deploys a demo web application (https://github.com/GoogleCloudPlatform/microservices-demo), composed of 11 microservices, on AWS EKS provisioned with Terraform. <br>Kube Prometheus Stack provides Prometheus and Grafana for Kubernetes monitoring. <br>Grafana Alloy collects Kubernetes pod logs and sends them to Loki, where Grafana can be used to visualize the logs and metrics.

## Architecture

![Architecture Diagram](/images/architecture-diagram.png)

## Screenshots

Grafana Dashboard
![Screenshot of the Grafana Dashboard](/images/Dashboard.png)

## Setup

Ensure you have `git`, `aws`, `terraform`, `kubectl` and `helm` installed and configured.

0. Backend

   The S3 bucket should be created in the AWS for storing the `terraform.tfstate` file.
   <br>Details are in the `/terraform/backend.tf`


2. Clone the repository

   ```sh
   git clone https://github.com/sydoruka/aws-eks-observability.git
   cd aws-eks-observability/
   ```

3. Create the EKS cluster.

   ```sh
   cd terraform/
   terraform init
   terraform --plan out tfplan
   terraform apply tfplan
   ```

   Creating the cluster may take 10-15 minutes.

4. Update the EKS endpoint
   ```sh
   aws eks update-kubeconfig --region eu-central-1 --name eks-practice-al2023
   ```

5. Deploy the application to the cluster.

   ```sh
   kubectl apply -f ../release/kubernetes-manifests.yaml
   helm install loki ../helm-charts/loki -n monitoring
   ```

4. Access the web frontend in a browser using the frontend's external IP.

   ```sh
   kubectl get service frontend-external | awk '{print $4}'
   ```

   Visit `http://EXTERNAL_IP` in a web browser to access your instance of the app.

5. Access the Grafana instance locally
   ```sh
   export POD_NAME=$(kubectl -n monitoring get pod -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=kube-prometheus-stack" -oname)
   kubectl -n monitoring port-forward $POD_NAME 3000
   ```
   Get Grafana 'admin' user password by running:
   ```sh
   kubectl -n monitoring get secrets kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo
   ```
   Visit `http://localhost:3000` in a web browser to access your instance of Grafana.<br>
   Import the `Grafana-Dashboard.json` into Grafana and monitor the application.

6. Once you are done with it, delete the EKS cluster.

   ```sh
   helm uninstall loki -n monitoring
   kubectl delete -f ../release/kubernetes-manifests.yaml
   terraform destroy
   ```

   Deleting the cluster may take 10-15 minutes.
