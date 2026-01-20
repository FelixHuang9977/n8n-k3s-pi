#!/bin/bash

echo "=== K3s n8n Troubleshooting ==="
echo ""

echo "1. Checking namespace..."
kubectl get namespace n8n

echo ""
echo "2. Checking n8n deployment..."
kubectl get deployment -n n8n

echo ""
echo "3. Checking n8n pods..."
kubectl get pods -n n8n

echo ""
echo "4. Checking n8n service..."
kubectl get svc -n n8n

echo ""
echo "5. Checking ingress-nginx namespace..."
kubectl get namespace ingress-nginx

echo ""
echo "6. Checking ingress controller pods..."
kubectl get pods -n ingress-nginx

echo ""
echo "7. Checking ingress controller service..."
kubectl get svc -n ingress-nginx

echo ""
echo "8. Checking ingress resource..."
kubectl get ingress -n n8n

echo ""
echo "9. Ingress details..."
kubectl describe ingress n8n-ingress -n n8n

echo ""
echo "10. Getting node IP..."
kubectl get nodes -o wide

echo ""
echo "=== Access Information ==="
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=$(kubectl get svc -n ingress-nginx nginx-ingress-n8n -o jsonpath='{.spec.ports[0].nodePort}')

echo "Try accessing n8n at:"
echo "  http://${NODE_IP}:${NODE_PORT}"
echo ""
echo "If using LoadBalancer, check external IP:"
kubectl get svc -n n8n n8n-service -o wide
