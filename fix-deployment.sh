#!/bin/bash
# Fix n8n deployment on Raspberry Pi k3s

echo "=== Fixing n8n Deployment ==="

# Step 1: Delete the failing deployment
echo ""
echo "1. Removing failed deployment..."
kubectl delete deployment n8n-deployment -n n8n

# Step 2: Check pod is deleted
echo ""
echo "2. Waiting for pod to terminate..."
kubectl wait --for=delete pod -l app=n8n -n n8n --timeout=60s 2>/dev/null || echo "Pods already deleted"

# Step 3: Describe the pod to see the exact error (if it still exists)
echo ""
echo "3. Getting pod details..."
POD_NAME=$(kubectl get pods -n n8n -l app=n8n -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD_NAME" ]; then
  kubectl describe pod $POD_NAME -n n8n | grep -A 10 "Events:"
fi

# Step 4: Apply the corrected deployment
echo ""
echo "4. Applying corrected deployment..."
kubectl apply -f n8n-deployment.yaml

# Step 5: Wait for pod to be ready
echo ""
echo "5. Waiting for n8n pod to start (this may take 1-2 minutes)..."
kubectl wait --for=condition=ready pod -l app=n8n -n n8n --timeout=120s

# Step 6: Check status
echo ""
echo "6. Current status:"
kubectl get pods -n n8n
kubectl get svc -n n8n

# Step 7: Get access information
echo ""
echo "=== Access Information ==="
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl get svc n8n-service -n n8n -o jsonpath='{.spec.ports[0].nodePort}')

echo ""
echo "✅ n8n should be accessible at:"
echo "   http://${NODE_IP}:${NODE_PORT}"
echo ""
echo "To check logs:"
echo "   kubectl logs -n n8n -l app=n8n -f"
