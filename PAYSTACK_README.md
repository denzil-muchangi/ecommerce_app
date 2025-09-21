# Paystack Setup Guide

This guide will help you set up Paystack payment integration for the E-Commerce Flutter app.

## Prerequisites

- A Paystack account (sign up at [paystack.com](https://paystack.com))
- Your app's checkout screen is already configured to use Paystack

## Step 1: Create a Paystack Account

1. Go to [paystack.com](https://paystack.com) and click "Sign Up"
2. Choose your account type (Individual or Business)
3. Complete the registration process
4. Verify your email address

## Step 2: Set Up Your Business Profile

1. In your Paystack dashboard, go to Settings > Business
2. Fill in your business information
3. Add your business logo and branding
4. Set up your notification preferences

## Step 3: Get Your API Keys

1. In your Paystack dashboard, go to Settings > API Keys & Webhooks
2. You'll see your:
   - **Public Key** (starts with `pk_test_` for test mode or `pk_live_` for live mode)
   - **Secret Key** (starts with `sk_test_` or `sk_live_`)

**Important**: Keep your secret key secure and never expose it in client-side code.

## Step 4: Configure API Keys in Your App

1. Open `lib/screens/checkout_screen.dart`
2. Find the line:
   ```dart
   plugin.initialize(publicKey: 'pk_test_your_paystack_public_key_here');
   ```
3. Replace `'pk_test_your_paystack_public_key_here'` with your actual public key from Paystack

For production, use your live public key. For development/testing, use the test key.

## Step 5: Set Up Webhooks (Optional but Recommended)

Webhooks allow Paystack to notify your app of payment events.

1. In your Paystack dashboard, go to Settings > API Keys & Webhooks
2. Click "Add Webhook"
3. Enter your webhook URL (your server endpoint that will handle webhook events)
4. Select the events you want to listen for (e.g., charge.success, charge.failed)
5. Save the webhook

## Step 6: Test Payments

1. Use your test API keys for development
2. Paystack provides test card numbers for testing:
   - Successful: `4084084084084081`
   - Declined: `4084084084084082`
   - Insufficient funds: `4084084084084083`
   - Use any future expiry date and any 3-digit CVV

## Step 7: Go Live

When you're ready for production:

1. Replace test API keys with live keys in your app
2. Update any test webhook URLs to production URLs
3. Ensure your business profile is complete
4. Submit your account for review if required
5. Start accepting real payments

## Step 8: Monitor Transactions

1. Use the Paystack dashboard to monitor transactions
2. Set up email notifications for payment events
3. Review failed payments and implement retry logic if needed

## Additional Configuration

### Currency
Paystack supports multiple currencies. The app uses NGN (Nigerian Naira) by default. Update the currency in your checkout logic if needed.

### Payment Methods
The app currently supports card payments. Paystack also supports bank transfers, mobile money, etc. You can extend the payment options in the checkout screen.

### Error Handling
The app already includes basic error handling for payment failures. Consider adding more sophisticated error handling and user feedback.

## Troubleshooting

- **Payment fails**: Check your API keys and ensure you're using test keys for testing
- **Webhook not working**: Verify the webhook URL is accessible and handles POST requests
- **App crashes**: Ensure the public key is correctly set and the Paystack plugin is properly initialized

For more detailed documentation, visit the [Paystack Developer Documentation](https://developers.paystack.co/docs).