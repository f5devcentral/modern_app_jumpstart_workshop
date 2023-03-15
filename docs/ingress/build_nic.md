# Build NGINX Plus Ingress Controller Container

In this step, you will build a copy of the NGINX Plus Ingress Controller container and push it to your private container registry.

**Note:** We **HIGHLY** discourage you from publishing your NGINX Plus containers to a public registry. Please ensure you are publishing the containers from this lab to a private registry such as [GitHub Packages](https://github.com/features/packages) or [Docker Hub](https://hub.docker.com/).

You can also reference the official [NGINX Ingress Controller documentation](https://docs.nginx.com/nginx-ingress-controller/) for additional details.

## Clone the NGINX Ingress Controller Repository

1. In your terminal, clone the Official [NGINX Ingress Controller repository](https://github.com/nginxinc/kubernetes-ingress.git)

    **Note:** You may need to update the branch version to match the latest release of NGINX Ingress Controller

    ```bash
    git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v3.0.2
    cd kubernetes-ingress
    ```

## Build the Container

For this step, we will leverage the [Docker CLI](https://docs.docker.com/engine/install/) to build the NGINX Ingress Controller image.

The repository's Makefile supports several [target types](https://docs.nginx.com/nginx-ingress-controller/installation/building-ingress-controller-image/#makefile-targets), but for this lab we will leverage the *debian-image-nap-dos-plus* target so we can use NGINX App Protect WAF.

> **Note:** For additional details you can also reference the [Build the Ingress Controller Image](https://docs.nginx.com/nginx-ingress-controller/installation/building-ingress-controller-image/) portion of the [NGINX Ingress Controller documentation](https://docs.nginx.com/nginx-ingress-controller/).

1. Make sure that the certificate (nginx-repo.crt) and the key (nginx-repo.key) of your license are located in the root of the project:

    ```bash
    ls nginx-repo.*
    nginx-repo.crt  nginx-repo.key
    ```

    >Note: The certificate's file extension *must* be `.crt`. If the file extension is downloaded as anything else (such as `.cer`), you must rename the file yourself before proceeding.

1. To build the NGINX Ingress Controller container, follow these steps:

    ```bash
    # Replace your_github_username with your Github username
    export GITHUB_USER=your_github_username

    make debian-image-nap-dos-plus PREFIX=ghcr.io/$GITHUB_USER/nginx-plus-ingress TARGET=container DOCKER_BUILD_OPTIONS="--platform linux/amd64"
    ```

## Publish the Container

To publish the NGINX Ingress Controller container to your private registry follow the following steps:

1. Create a [GitHub PAT (Personal Access Token)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the following scopes:
    - *read:packages*
    - *write:packages*
    - *delete:packages*

1. Export the value to the *GITHUB_TOKEN* environment variable.

    ```bash
    export GITHUB_TOKEN=your_access_token
    ```

1. Run the *docker login* command to log into the [GitHub Package](https://github.com/features/packages) container registry with your PAT:

    ```bash
    # Login to GitHub Packages
    echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USER --password-stdin

    # Find your container tag
    TAG=`docker images ghcr.io/$GITHUB_USER/nginx-plus-ingress --format "{{.Tag}}"`

    # Publish the container
    docker push ghcr.io/$GITHUB_USER/nginx-plus-ingress:$TAG
    ```

    > **Note:** If you had previously created and tagged an `nginx-plus-ingress` container image on your system, the command above used to set the `TAG` variable will not work. Instead, run `docker images ghcr.io/$GITHUB_USER/nginx-plus-ingress --format "{{.Tag}}"` and select your most recent tag from the output, then set the variable manually: `TAG=<your tag from the previous command>`.

## Next Steps

Now you can [install the NGINX Plus Ingress Controller](install_nic.md)
