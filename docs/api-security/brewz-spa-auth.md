# Integrate Authentication and Authorization into Brewz SPA application

The Brewz developers have already completed the work to integrate the SPA application with Azure for authentication. Since they are integrating with Azure, they chose the [Microsoft Authentication Library (MSAL)](https://learn.microsoft.com/en-us/azure/active-directory/develop/msal-overview) for which provides a Javascript API for ease of integration into their SPA.

For detailed information about how the Brewz application registrations for the SPA and API components were set up in Azure, refer to the following procedures:

- [Register an application with the Microsoft identity platform](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)

- [Configure an application to expose a web API](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-configure-app-expose-web-apis)

For testing purposes, anyone that has an account within F5's Azure Active Directory will be able to sign in to the Brewz application. If the user clicks the **Sign In** and is not already authenticated, they will be redirected to Azure to sign in authorize the Brewz application to use their basic profile information. Once the user is authenticated and authorization is complete, they will be redirected back to the Brewz application where they will be able to continue the checkout process.

## Enabling security in the SPA

The Brewz developers have made use of a feature flag in the SPA application to expose the areas of the application that require a login.

1. Open the **Brewz** UDF access method on the **k3s** component.

1. Click **Shopping Cart**. By default, there should be a few items in your shopping cart. Note that there is no **Checkout** button.

1. In the URL, replace `products` with `config` and hit enter. You will be presented with the config page:

    <img src="../assets/spa_enable_security.png" alt="SPA enable security" width="400"/>

1. Check the checkbox by **Enable Security**, then refresh your browser.

1. Click the **BREWZ** title to navigate to the product page. You should now see a **Sign In** button in the header:

    <img src="../assets/spa_sign_in_button.png" alt="Sign In button" width="600"/>

1. Click the **Shopping Cart** button, then click the **Proceed to Checkout** button at the bottom of the page.

    <img src="../assets/spa_sign_in_required.png" alt="Sign in required" width="600"/>

    > **Note:** The application contains logic that will not let you proceed to protected views unless you are signed in.

## Sign In

1. Click the **Sign In** button in the navigation header. If this is your first time signing into the Brewz app, you should be redirected to Microsoft's sign in pages and will see the following prompts. If not, jump directly to [Signed In](#signed-in).

1. On the email page, enter your full F5 email address. Do not enter an email alias.

    <img src="../assets/msft_email.png" alt="Sign In with your email address" width="400"/>

1. On the password page, enter your F5 account password, and click **Sign In**.

    <img src="../assets/msft_password.png" alt="Enter your password" width="400"/>

1. If you are prompted to **Stay Signed In**, you may pick either option you prefer to continue.

    <img src="../assets/msft_stay_signed_in.png" alt="Enter your password" width="400"/>

## Signed In

Once sign in is complete, you should be redirected back to the Brewz application. Notice additional links and buttons now appear in the navigation bar:

<img src="../assets/spa_signed_in_header.png" alt="Signed into the Brewz SPA app" width="650"/>

1. Click the **Shopping Cart** button, then click the **Proceed to Checkout** button at the bottom of the page. The **Checkout** page will appear:

    <img src="../assets/spa_checkout.png" alt="Checkout page" width="650"/>

1. In your browser, open the developer tools window. Open the **Network** pane so that you can see the API calls that are made for the next step. Specific steps will likely vary based upon your browser of choice.

1. Click the **Complete Purchase** button at the bottom of the page. The page will show a **Purchase Complete** dialog showing an Order ID.

1. In your developer toolbar, see that the SPA app has invoked a `POST` method on the `/api/order` URI. `Order` is an operation on the **Checkout** service we deployed earlier:

    <img src="../assets/spa_checkout_confirmed_api.png" alt="Checkout complete with developer tools" width="650"/>

1. Click the **Payload** tab in your developer toolbar. See that the SPA app passed the cart items, a shipping address an a user ID to the service.

    <img src="../assets/spa_checkout_confirmed_payload.png" alt="Inspecting the order payload" width="650"/>

1. Click the **Response** tab in your developer toolbar. The value of the `orderId` JSON property should match what is displayed on the page.

    <img src="../assets/spa_checkout_confirmed_response.png" alt="Inspecting the order response" width="650"/>

1. Click the headers toolbar once again in your developer toolbar. Scroll until **Request Headers** is in view. Note the `Authorization: Bearer...` token. This is the JWT token for the Brewz API that the SPA is sending to the Checkout service when placing an order.

    <img src="../assets/spa_checkout_confirmed_headers.png" alt="Inspecting the order headers" width="650"/>

    What is in this JWT token?

## Next Steps

Next, we will [inspect the contents of this JWT token](jwt-token.md).
