## Intro

The ArgoCD app-of-app pattern involves defining an application (app) that deploys other apps.


![](https://github.com/Intility/example-argo-gitops-repo/blob/main/img/argo.gif)


In the GIF above, `.bootstrap/dev.yaml` creates an app configured with this repository URL and the "dev" directory as path:

```
    path: 'dev'
    repoURL: 'https://github.com/Intility/example-argo-gitops-repo.git'
```

The `dev` directory/path contains the manifests for the desired ArgoCD Projects and Applications.


When pressing sync on the bootstrap-app, all the projects and applications defined in the `dev` directory will be created.

![](https://github.com/Intility/example-argo-gitops-repo/blob/main/img/appofapps.png)

The process of adding new apps to this project could be further streamlined with a Backstage template.


## Running locally:


Run `sh .local/install.sh` script to create local Kind or Minikube cluster and start Argo CD.

Create the bootstrap app with `kubectl apply -f .bootstrap/dev.yaml`

To remove the local cluster you can run `kind delete cluster --name my-cluster` if you're using Kind and `minikube delete` if you're using minikube.
