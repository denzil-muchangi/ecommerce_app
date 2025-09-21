# Paystack Webhook Setup Guide

This guide provides detailed instructions for setting up webhooks in Paystack to handle payment events for your E-Commerce Flutter app.

## What are Webhooks?

Webhooks are automated messages sent from Paystack to your server when specific events occur. Unlike polling (where your app repeatedly checks for updates), webhooks push real-time notifications to your server, making them more efficient and reliable for handling payment events.

## Why Use Webhooks?

- **Real-time Updates**: Get instant notifications when payments succeed, fail, or are refunded
- **Reliability**: Don't miss important payment events due to app crashes or network issues
- **Security**: Server-side verification of payment status
- **Automation**: Automatically update order status, send receipts, or trigger fulfillment processes

## Prerequisites

- A Paystack account with API keys configured
- A backend server or cloud function to receive webhook events
- HTTPS endpoint (Paystack requires secure connections for webhooks)

## Step 1: Access Webhook Settings

1. Log in to your [Paystack Dashboard](https://dashboard.paystack.com)
2. Navigate to **Settings** in the left sidebar
3. Click on **API Keys & Webhooks**

## Step 2: Add a New Webhook

1. In the API Keys & Webhooks section, scroll down to the **Webhooks** section
2. Click the **Add Webhook** button
3. Fill in the webhook details:

### Webhook URL
Enter your server's endpoint URL that will receive webhook events. This should be:
- A publicly accessible HTTPS URL
- Capable of handling POST requests
- Configured to process JSON payloads

Example: `https://yourdomain.com/api/paystack/webhook`

### Events to Listen For
Select the events you want to receive notifications for:

**Essential Events:**
- `charge.success` - When a payment is successful
- `charge.failed` - When a payment fails
- `transfer.success` - When a transfer/payout succeeds
- `transfer.failed` - When a transfer/payout fails

**Additional Events (Recommended):**
- `subscription.create` - When a subscription is created
- `subscription.disable` - When a subscription is disabled
- `invoice.create` - When an invoice is created
- `invoice.update` - When an invoice is updated

## Step 3: Save the Webhook

1. Click **Save** to create the webhook
2. Paystack will send a test event to verify your endpoint
3. Your server should respond with a `200 OK` status to confirm receipt

## Step 4: Implement Webhook Handler on Your Server

### Backend Implementation

Create an endpoint on your server to handle webhook events. Here's an example using Node.js/Express:

```javascript
const express = require('express');
const crypto = require('crypto');
const app = express();

app.use(express.json());

// Paystack webhook secret (set this in your environment variables)
const PAYSTACK_SECRET = process.env.PAYSTACK_SECRET;

app.post('/api/paystack/webhook', (req, res) => {
  // Verify webhook signature
  const hash = crypto
    .createHmac('sha512', PAYSTACK_SECRET)
    .update(JSON.stringify(req.body))
    .digest('hex');

  if (hash !== req.headers['x-paystack-signature']) {
    return res.status(400).send('Invalid signature');
  }

  const event = req.body;

  // Handle different event types
  switch (event.event) {
    case 'charge.success':
      handleSuccessfulPayment(event.data);
      break;
    case 'charge.failed':
      handleFailedPayment(event.data);
      break;
    case 'transfer.success':
      handleSuccessfulTransfer(event.data);
      break;
    default:
      console.log('Unhandled event type:', event.event);
  }

  res.status(200).send('Webhook received');
});

function handleSuccessfulPayment(data) {
  const { reference, amount, customer, metadata } = data;

  // Update order status in your database
  // Send confirmation email
  // Trigger fulfillment process
  console.log(`Payment successful: ${reference}, Amount: ${amount}`);
}

function handleFailedPayment(data) {
  const { reference, customer } = data;

  // Update order status to failed
  // Notify customer of failure
  // Log failure for analysis
  console.log(`Payment failed: ${reference}`);
}

function handleSuccessfulTransfer(data) {
  const { reference, amount } = data;

  // Update payout status
  // Send notification to merchant
  console.log(`Transfer successful: ${reference}, Amount: ${amount}`);
}

app.listen(3000, () => {
  console.log('Webhook server running on port 3000');
});
```

### Python/Django Example

```python
import json
import hmac
import hashlib
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.conf import settings

@csrf_exempt
def paystack_webhook(request):
    if request.method != 'POST':
        return HttpResponse(status=405)

    # Verify webhook signature
    paystack_secret = settings.PAYSTACK_SECRET.encode('utf-8')
    signature = request.META.get('HTTP_X_PAYSTACK_SIGNATURE')
    computed_hash = hmac.new(paystack_secret, request.body, hashlib.sha512).hexdigest()

    if not hmac.compare_digest(computed_hash, signature):
        return HttpResponse('Invalid signature', status=400)

    try:
        event = json.loads(request.body)
    except json.JSONDecodeError:
        return HttpResponse('Invalid JSON', status=400)

    # Handle events
    if event['event'] == 'charge.success':
        handle_successful_payment(event['data'])
    elif event['event'] == 'charge.failed':
        handle_failed_payment(event['data'])

    return HttpResponse('Webhook received', status=200)

def handle_successful_payment(data):
    reference = data['reference']
    amount = data['amount']
    customer = data['customer']

    # Update your database
    # Send notifications
    print(f"Payment successful: {reference}")
```

### PHP/Laravel Example

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class PaystackWebhookController extends Controller
{
    public function handleWebhook(Request $request)
    {
        // Verify signature
        $paystackSecret = env('PAYSTACK_SECRET');
        $signature = $request->header('X-Paystack-Signature');
        $computedHash = hash_hmac('sha512', $request->getContent(), $paystackSecret);

        if (!hash_equals($computedHash, $signature)) {
            return response('Invalid signature', 400);
        }

        $event = json_decode($request->getContent(), true);

        // Handle events
        switch ($event['event']) {
            case 'charge.success':
                $this->handleSuccessfulPayment($event['data']);
                break;
            case 'charge.failed':
                $this->handleFailedPayment($event['data']);
                break;
        }

        return response('Webhook received', 200);
    }

    private function handleSuccessfulPayment($data)
    {
        $reference = $data['reference'];
        $amount = $data['amount'];

        // Update database
        // Send notifications
        Log::info("Payment successful: {$reference}");
    }

    private function handleFailedPayment($data)
    {
        $reference = $data['reference'];

        // Update order status
        Log::error("Payment failed: {$reference}");
    }
}
```

## Step 5: Webhook Security

### Signature Verification
Always verify the webhook signature to ensure the request comes from Paystack:

1. Get the `X-Paystack-Signature` header
2. Compute HMAC SHA512 hash of the request body using your secret key
3. Compare with the signature header

### IP Whitelisting (Optional)
Paystack sends webhooks from specific IP addresses. You can whitelist these IPs for additional security:

- 52.31.139.75
- 52.49.173.169
- 52.214.14.220

## Step 6: Test Your Webhook

1. Use Paystack's test environment
2. Make test payments in your app
3. Check your server logs to confirm webhook receipt
4. Verify that your application correctly processes the events

## Step 7: Handle Webhook Events in Your Flutter App

While webhooks are primarily server-side, you can update your Flutter app based on webhook notifications:

```dart
// In your order service or BLoC
void updateOrderStatus(String orderId, String status) {
  // Update local database
  // Refresh UI
  // Send push notifications
}

// Call this when webhook confirms payment
void handlePaymentConfirmation(Map<String, dynamic> webhookData) {
  final orderId = webhookData['metadata']['order_id'];
  final status = webhookData['status'];

  updateOrderStatus(orderId, status);
}
```

## Common Webhook Events

| Event | Description | Action Required |
|-------|-------------|----------------|
| `charge.success` | Payment completed successfully | Update order status, send receipt |
| `charge.failed` | Payment failed | Update order status, notify customer |
| `transfer.success` | Payout completed | Update payout status |
| `transfer.failed` | Payout failed | Handle payout failure |
| `subscription.create` | New subscription created | Activate subscription |
| `subscription.disable` | Subscription cancelled | Deactivate subscription |

## Troubleshooting

### Webhook Not Received
- Check that your endpoint is publicly accessible
- Verify HTTPS is enabled
- Confirm firewall allows POST requests
- Check server logs for errors

### Invalid Signature
- Ensure you're using the correct secret key
- Verify signature verification logic
- Check for extra whitespace in your secret

### Duplicate Events
- Implement idempotency using the event ID
- Store processed event IDs to prevent duplicates

### Timeout Issues
- Respond with 200 OK immediately
- Process events asynchronously
- Set appropriate timeouts on your server

## Best Practices

1. **Respond Quickly**: Always return a 200 status code immediately
2. **Process Asynchronously**: Handle complex logic in background jobs
3. **Log Events**: Keep detailed logs for debugging
4. **Handle Failures**: Implement retry logic for failed operations
5. **Monitor**: Set up alerts for webhook failures
6. **Test Thoroughly**: Test all event types in sandbox mode

## Additional Resources

- [Paystack Webhook Documentation](https://developers.paystack.co/docs/webhooks)
- [Webhook Security Best Practices](https://developers.paystack.co/docs/webhooks#security)
- [Event Types Reference](https://developers.paystack.co/docs/events)