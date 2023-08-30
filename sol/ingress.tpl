apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: demo-app
  template:
    metadata:
      labels:
        app: demo-app
    spec:
      containers:
      - name: demo-container
        image: paulbouwer/hello-kubernetes:1.10
        ports:
          - containerPort: 80
 
---

apiVersion: v1
kind: Service
metadata:
  name: demo-service
spec:
  selector:
    app: demo-app
  ports:
    - port: 80
      targetPort: 8080
 
---

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
spec:
  ingressClassName: nginx
  rules:
    - host: groupeGRP.randco.eu
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: demo-service
                port:
                  number: 80
