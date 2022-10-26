# Securing the Checkout service

Earlier in the lab, we observed that the Brewz SPA was calling the Checkout API's order operation to finalize the order process. We also observed the `Authorization: bearer` header was present, containing the JWT token. Were either the presence or the content of this token being validated? Let's find out...

1. Open the **Brewz** UDF access method on the **k3s** component and ensure you are signed in. If so, your name should appear in the greeting text in the header.

1. Click the **Shopping Cart** button. Ensure that there is at least one item in your shopping cart before proceeding.

1. In the **Shopping Cart** view, click the **Proceed to Checkout** button at the bottom. The **Checkout** view will appear:

    <img src="../assets/spa_checkout.png" alt="Checkout view" width="650"/>

1. In your browser, open the developer tools window. Open the **Network** pane so that you can see the API calls that are made for the next step. Specific steps will likely vary based upon your browser of choice.

1. Click the **Complete Purchase** button at the bottom of the view. The SPA will show a **Purchase Complete** dialog showing an Order ID.

1. In your developer toolbar, see that the SPA app has invoked a `POST` method on the `/api/order` URI.

    <img src="../assets/spa_checkout_confirmed_api.png" alt="Checkout complete with developer tools" width="650"/>

1. In your developer toolbar right-click on the `order` request, and click **Copy** -> **Copy as cURL**.

    <img src="../assets/spa_order_copy_curl.png" alt="Copy order request as cURL command" width="650"/>

    > **Note:** If you browser's developer tools does not support exporting a request as cURL, use the following command, but replace `<brewz host name>` with the host name of your Brewz application:

    ```bash
    curl 'https://<brewz host name>/api/order' \
    -H 'Accept: application/json, text/plain, */*' \
    -H 'Accept-Language: en-US,en;q=0.9' \
    -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJ...(redacted)' \
    -H 'Cache-Control: no-cache' \
    -H 'Connection: keep-alive' \
    -H 'Content-Type: application/json' \
    -H 'Pragma: no-cache' \
    -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
    --data-raw '{"products":[{"id":"123"}],"shippingAddress":{"street":"801 5th Ave","city":"Seattle","state":"WA","zip":"98104"},"userId":"12345"}' \
    --compressed
    ```

1. Paste the request into an editor, such as VS Code.

1. Locate and delete the `Authorization` header line from the cURL command:

    <img src="../assets/vscode_order_service_curl_2.png" alt="cURL command for order operation" width="650"/>

1. Copy the modified cURL command into your terminal, and execute it:

    <img src="../assets/term_order_service_curl.png" alt="Executing cURL command for order operation" width="750"/>

    Notice that an `orderId` is returned from the API call. This indicates that the presence of the authorization token is not being enforced! We need to fix this ASAP!!!

    > **Note:** Save this command somewhere, as you will be using it again later in this lab.

## Next Steps

Use NGINX Ingress Controller to [inspect and enforce the JWT token](enforce-jwt.md).
