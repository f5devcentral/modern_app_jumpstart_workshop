# Lab 4: Microservices API Security

In this lab you will integrate security features into the Brewz application, and use NGINX Ingress Controller to authorize access to specific APIs.

If you have completed the earlier labs in this workshop, you would have learned about the Brewz company, and their digital transformation efforts to date. If not, you can read about them [here](../scenario/README.md#brewz-company-overview).

> **Note:** Though it is *recommended*, it is **not required** that you complete labs 1-3 of this series before starting this lab.

## Requirements

For this lab, you will need:

- An F5.com account that is present in F5's Azure Active Directory
- [GitHub account](https://github.com)
- [Visual Studio Code](https://code.visualstudio.com/)
- [git](https://git-scm.com/downloads)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [GitHub CLI - optional](https://cli.github.com/)
- [cURL](https://curl.se/) - Usually pre-installed in Unix-based Operating systems, available when using Windows with WSL installed.

> **Note:** You will also need to request an NGINX Plus trial via SalesForce to obtain an NGINX Plus JWT file in order to deploy NGINX Ingress Controller from the NGINX official private registry.

## Resources

- [NGINX Ingress Controller documentation](https://docs.nginx.com/nginx-ingress-controller/)
- [Microsoft Authentication Library (MSAL)](https://learn.microsoft.com/en-us/azure/active-directory/develop/msal-overview)
- [JSON Web Token (JWT)](https://jwt.io/)

## Steps

- [Setup](setup.md) the lab
- Examine the [Checkout process](checkout-process.md) overview
- Deploy the [Checkout service](checkout-service.md)
- Enable [authentication and authorization in the Brewz SPA application](brewz-spa-auth.md)
- [Inspect the Brewz API JWT](jwt-token.md)
- [Secure the Checkout service](securing-checkout.md)
- [Inspect and enforce the JWT](enforce-jwt.md)
- [Use JWT claim data](claim-data.md)
