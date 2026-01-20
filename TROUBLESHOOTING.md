# K3s n8n External Access Troubleshooting

## Current Setup
- Service Type: NodePort
- Ingress: nginx
- NodePort configured: 5678

## ✅ Raspberry Pi 32-bit Configuration (Working)

Your setup requires specific settings because of the 32-bit ARM architecture and limited RAM.

### 1. Docker Image
- **Image:** `n8nio/n8n:1.26.0`
- **Reason:** Latest versions do not support 32-bit ARMv7.

### 2. Resources
- **Memory Request:** `250Mi` (Lowered from 512Mi)
- **Reason:** Prevents "Insufficient memory" scheduling errors.

### 3. Health Checks
- **InitialDelay:** `60s`
- **Reason:** Raspberry Pi takes longer to start the application.

If you ever need to re-deploy, ensure `n8n-deployment.yaml` keeps these values.

**Current Access:** Your n8n is configured as NodePort on port **32191**
```bash
# Access at:
http://192.168.1.108:32191
```

## Quick Access Methods


### Method 1: NodePort Access (Current)
```bash
# Get your node IP
kubectl get nodes -o wide

# Access n8n at:
http://<NODE_IP>:5678
```

### Method 2: LoadBalancer (Recommended)
```bash
# Apply the LoadBalancer service
kubectl apply -f n8n-service-loadbalancer.yaml

# Check external IP
kubectl get svc -n n8n n8n-service

# Access at the EXTERNAL-IP shown
```

### Method 3: Port Forward (Testing)
```bash
kubectl port-forward -n n8n svc/n8n-service 8080:80

# Access at:
http://localhost:8080
```

## Troubleshooting Steps

### 1. Verify All Resources Are Running
```bash
bash troubleshoot.sh
```

### 2. Check Firewall Rules
```bash
# Allow port 5678
sudo firewall-cmd --permanent --add-port=5678/tcp
sudo firewall-cmd --reload
# OR
sudo ufw allow 5678/tcp
```

### 3. Verify Ingress Controller
```bash
# Check if ingress-nginx is installed
kubectl get pods -n ingress-nginx

# If not, install it:
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

### 4. Check Service Endpoints
```bash
kubectl get endpoints -n n8n n8n-service
```

### 5. View Logs
```bash
# n8n pod logs
kubectl logs -n n8n -l app=n8n

# Ingress controller logs
kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx
```

## Common Issues

### Issue: "Connection Refused"
- Check firewall rules
- Verify pod is running: `kubectl get pods -n n8n`
- Check pod logs for errors

### Issue: "Timeout" or "No Route"
- Verify network connectivity to node
- Check if k3s is running: `sudo systemctl status k3s`
- Verify node IP is correct

### Issue: LoadBalancer "Pending"
- k3s uses servicelb (Klipper) by default
- External IP should appear after a few seconds
- If stuck, check: `kubectl get pods -n kube-system -l app=svclb-n8n-service`

## Deployment Commands

```bash
# Deploy all resources
kubectl apply -f n8n-secrets.yaml
kubectl apply -f n8n-configmap.yaml
kubectl apply -f n8n-deployment.yaml
kubectl apply -f n8n-service.yaml
kubectl apply -f ingress/

# Or use LoadBalancer instead:
kubectl apply -f n8n-service-loadbalancer.yaml
```

## Getting Your Access URL

```bash
# For NodePort:
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "Access n8n at: http://${NODE_IP}:5678"

# For LoadBalancer:
kubectl get svc -n n8n n8n-service
# Use the EXTERNAL-IP shown
```
