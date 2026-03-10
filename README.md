# cluster-reply-onboarding
**Ziel**: AKS-Deployment durch Terraform via GitHub Actions-Pipeline nach manuellem *approval*.  Anschließendes Deployment einer Beispielanwendung und das *Exposen* via Traefik.

1. Automatisches *triggern* der Pipeline durch Änderungen an einer oder beiden Dateien `main.tf` und `github workflows/pipeline.yaml`
    1. Im 1. Job wird `terraform plan` ausgeführt
    2. Im 2. Job wird muss für das `terraform apply` manuell *approved* werden
    3. Dafür wird der 2. Job in einem geschütztem `Environment` ausgeführt.
    4. AKS wird *deployt*

2. Mit dem Azure Acc einloggen (beliebige Auth-Methode)
    ```bash
    az login
    # dann mit Account einloggen
    ```
3. K8s-Credentials in Konfig speichern
    ```bash
    az aks get-credentials --resource-group "rg-dimi" --name "dimi-aks-demo"
    ```
    > **Ausgabe:** Merged "dimi-aks-demo" as current context in C:\Users\d.chalatsoglou\.kube\config
4. *kubectl* installieren
    ```bash
    az aks install-cli
    ```
5. Testen
    ```bash
    kubectl get nodes
    ```
6. Kubernetes-Ressoucen *applien*\
**Konzept:**
    1. Internet
    2. Azure Public IP
    3. Azure Load Balancer
    4. Traefik Service
    5. Traefik Pod
    6. Ingress Regel
    7. nginx-demo-service (ClusterIP)
    8. nginx Pod

    Die 3 Ressourcen *applien*:
    ```bash
    cd k8s
    kubectl apply -f deployment.yaml
    kubectl apply -f service.yaml
    kubectl apply -f ingress.yaml
    ```
    - Deployment (für Beispielapp)
    - Service (für Beispielapp)
    - Ingress (zum *Exposen*)
7. Traefik *deployen*\
    Helm installieren
    ```bash
    choco install kubernetes-helm
    ```
    Traefik als Ingresscontroller *deployen*
    ```bash
    helm repo add traefik https://traefik.github.io/charts

    helm repo update

    helm install traefik traefik/traefik \
      --namespace traefik \
      --create-namespace \
      --set service.type=LoadBalancer
    ```
    -> Traefik-Service bekommt öffentliche IP, unter der dann die Beispielapp aufrufbar ist