# 🔗 Paystack Webhook Setup Guide (Firebase/Flutter)

This guide shows you how to set up Paystack webhooks using Firebase Cloud Functions. Webhooks automatically notify your app when payments complete!

## 🤔 What are Webhooks?

Webhooks are like text messages from Paystack to your server. When a payment succeeds or fails, Paystack instantly sends your server a notification. No need to constantly check for updates!

## ✅ Why Use Webhooks?

- **Instant Updates**: Know immediately when payments complete
- **Never Miss Payments**: Server-side confirmation even if app crashes
- **Secure**: Verify payments on your server
- **Automate**: Auto-update orders, send emails, trigger shipping

## 📋 What You'll Need

- ✅ Firebase project (see FIREBASE_README.md)
- ✅ Paystack account with API keys (see PAYSTACK_README.md)
- ✅ Node.js installed on your computer
- ✅ Firebase CLI installed (`npm install -g firebase-tools`)

## Step 1: Access Webhook Settings

1. Log in to your [Paystack Dashboard](https://dashboard.paystack.com)
2. Navigate to **Settings** in the left sidebar
3. Click on **API Keys & Webhooks**

## Step 2: Add a New Webhook

1. In the API Keys & Webhooks section, scroll down to the **Webhooks** section
2. Click the **Add Webhook** button
3. Fill in the webhook details:

### Webhook URL
Enter your Firebase Cloud Function URL that will receive webhook events. After deploying your function, Firebase will provide you with a URL like:

`https://us-central1-your-project-id.cloudfunctions.net/paystackWebhook`

This URL will be:
- A publicly accessible HTTPS URL
- Capable of handling POST requests
- Configured to process JSON payloads

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

## Step 4: Set Up Firebase Cloud Functions

Since you're using Firebase, you'll handle webhooks using Firebase Cloud Functions. This provides a serverless backend that integrates seamlessly with your Firestore database.

### Initialize Cloud Functions

1. Install Firebase CLI if you haven't already:
   ```bash
   npm install -g firebase-tools
   ```

2. Initialize Cloud Functions in your project:
   ```bash
   firebase init functions
   ```

3. Choose your Firebase project and select TypeScript for the functions.

### Create the Webhook Function

Create a new function file `functions/src/paystack-webhook.ts`:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as crypto from 'crypto';

admin.initializeApp();

const PAYSTACK_SECRET = functions.config().paystack.secret;

export const paystackWebhook = functions.https.onRequest(async (req, res) => {
  // Only allow POST requests
  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  // Verify webhook signature
  const signature = req.headers['x-paystack-signature'] as string;
  const hash = crypto
    .createHmac('sha512', PAYSTACK_SECRET)
    .update(JSON.stringify(req.body))
    .digest('hex');

  if (hash !== signature) {
    console.error('Invalid webhook signature');
    res.status(400).send('Invalid signature');
    return;
  }

  const event = req.body;
  console.log('Received webhook event:', event.event);

  try {
    // Handle different event types
    switch (event.event) {
      case 'charge.success':
        await handleSuccessfulPayment(event.data);
        break;
      case 'charge.failed':
        await handleFailedPayment(event.data);
        break;
      case 'transfer.success':
        await handleSuccessfulTransfer(event.data);
        break;
      case 'transfer.failed':
        await handleFailedTransfer(event.data);
        break;
      default:
        console.log('Unhandled event type:', event.event);
    }

    res.status(200).send('Webhook received successfully');
  } catch (error) {
    console.error('Error processing webhook:', error);
    res.status(500).send('Internal server error');
  }
});

async function handleSuccessfulPayment(data: any) {
  const { reference, amount, customer, metadata } = data;
  const orderId = metadata?.order_id;

  console.log(`Processing successful payment: ${reference}, Amount: ${amount}`);

  if (orderId) {
    // Update order status in Firestore
    const orderRef = admin.firestore().collection('orders').doc(orderId);

    await orderRef.update({
      status: 'paid',
      paymentStatus: 'completed',
      paymentReference: reference,
      paidAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Update product stock if needed
    const orderDoc = await orderRef.get();
    const orderData = orderDoc.data();

    if (orderData?.items) {
      for (const item of orderData.items) {
        const productRef = admin.firestore().collection('products').doc(item.productId);
        await admin.firestore().runTransaction(async (transaction) => {
          const productDoc = await transaction.get(productRef);
          if (productDoc.exists) {
            const currentStock = productDoc.data()?.stock || 0;
            transaction.update(productRef, {
              stock: Math.max(0, currentStock - item.quantity),
              updatedAt: admin.firestore.FieldValue.serverTimestamp()
            });
          }
        });
      }
    }

    // Send push notification to user (if using FCM)
    if (customer?.email) {
      // You can integrate with Firebase Cloud Messaging here
      console.log(`Payment confirmed for order ${orderId}`);
    }
  }
}

async function handleFailedPayment(data: any) {
  const { reference, customer, metadata } = data;
  const orderId = metadata?.order_id;

  console.log(`Processing failed payment: ${reference}`);

  if (orderId) {
    // Update order status to failed
    await admin.firestore().collection('orders').doc(orderId).update({
      status: 'payment_failed',
      paymentStatus: 'failed',
      paymentReference: reference,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  }
}

async function handleSuccessfulTransfer(data: any) {
  const { reference, amount, recipient } = data;

  console.log(`Processing successful transfer: ${reference}, Amount: ${amount}`);

  // Update transfer/payout status
  // You might want to track payouts in a separate collection
  await admin.firestore().collection('transfers').doc(reference).update({
    status: 'completed',
    completedAt: admin.firestore.FieldValue.serverTimestamp()
  });
}

async function handleFailedTransfer(data: any) {
  const { reference, recipient } = data;

  console.log(`Processing failed transfer: ${reference}`);

  // Update transfer status and handle failure
  await admin.firestore().collection('transfers').doc(reference).update({
    status: 'failed',
    failedAt: admin.firestore.FieldValue.serverTimestamp()
  });
}
```

### Update Functions Index

In `functions/src/index.ts`, export your webhook function:

```typescript
export { paystackWebhook } from './paystack-webhook';
```

### Configure Environment Variables

Set your Paystack secret key:

```bash
firebase functions:config:set paystack.secret="your_paystack_secret_key_here"
```

### Deploy the Function

Deploy your Cloud Function:

```bash
firebase deploy --only functions:paystackWebhook
```

After deployment, Firebase will provide you with the function URL, which you'll use as your webhook URL in Paystack.

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

## Step 7: Listen to Firestore Changes in Your Flutter App

Since webhooks update your Firestore database, your Flutter app automatically sees changes in real-time!

### Real-time Order Updates

Your Flutter app can listen for order status changes:

```dart
// In your OrderBloc or order screen
Stream<Order> listenToOrderStatus(String orderId) {
  return FirebaseFirestore.instance
      .collection('orders')
      .doc(orderId)
      .snapshots()
      .map((doc) => Order.fromFirestore(doc));
}

// Use in your order confirmation screen
class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;

  const OrderConfirmationScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Order>(
      stream: listenToOrderStatus(orderId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final order = snapshot.data!;

          switch (order.status) {
            case 'paid':
              return PaymentSuccessWidget(order: order);
            case 'payment_failed':
              return PaymentFailedWidget(order: order);
            default:
              return OrderProcessingWidget(order: order);
          }
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
```

### Push Notifications (Optional)

Add Firebase Cloud Messaging for instant notifications:

```dart
// In main.dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (message.data['type'] == 'payment_success') {
    // Show in-app notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment confirmed for order ${message.data['orderId']}')),
    );
  }
});
```

---

## 🔒 Security Checklist

### ✅ Webhook Security
- [ ] Paystack secret key stored securely in Firebase config
- [ ] Webhook signature verification implemented
- [ ] HTTPS-only webhook URL
- [ ] Proper error handling and logging

### ✅ Firestore Security
- [ ] Security rules prevent unauthorized access
- [ ] Users can only access their own orders
- [ ] Admin-only access for product management
- [ ] Data validation in security rules

### ✅ App Security
- [ ] Paystack public key only in client code
- [ ] Secret keys never in app code
- [ ] Environment variables for different environments
- [ ] Input validation on all forms

---

## 🚨 Common Issues & Solutions

### Webhook Not Receiving Events
**Problem**: Paystack dashboard shows webhook failures
**Solutions**:
- Check Firebase function logs: `firebase functions:log`
- Verify webhook URL is correct
- Ensure function is deployed: `firebase functions:list`
- Check Paystack secret key is set correctly

### Invalid Signature Errors
**Problem**: Function logs show "Invalid signature"
**Solutions**:
- Verify secret key: `firebase functions:config:get`
- Check if using test/live keys correctly
- Ensure signature verification code is correct

### Orders Not Updating
**Problem**: Payment succeeds but order status doesn't change
**Solutions**:
- Check Firestore security rules
- Verify payment reference matching logic
- Look for errors in function logs
- Test with Firebase emulator locally

### Function Timeout
**Problem**: Function takes too long and times out
**Solutions**:
- Respond with 200 OK immediately
- Move heavy processing to background
- Use Firebase Cloud Tasks for long operations
- Optimize database queries

---

## 📊 Monitoring & Maintenance

### Check Function Performance
```bash
# View function metrics
firebase functions:list

# Check recent logs
firebase functions:log --only paystackWebhook --limit 10
```

### Monitor Paystack Dashboard
- View webhook delivery status
- Check for failed webhook attempts
- Monitor payment success rates
- Review error logs

### Regular Maintenance
- Update Firebase Functions regularly
- Monitor costs in Firebase Console
- Review and update security rules
- Test webhooks after deployments

---

## 🎯 Complete Setup Flow

1. ✅ Set up Firebase project
2. ✅ Configure Firestore security rules
3. ✅ Create Paystack account and get keys
4. ✅ Initialize Firebase Cloud Functions
5. ✅ Create and deploy webhook function
6. ✅ Configure webhook in Paystack dashboard
7. ✅ Test with sample payments
8. ✅ Add real-time listeners in Flutter app
9. ✅ Set up monitoring and alerts

Your complete payment system is now ready! 🎉

---

## 📚 Additional Resources

- [Firebase Cloud Functions Documentation](https://firebase.google.com/docs/functions)
- [Paystack Webhook Guide](https://developers.paystack.co/docs/webhooks)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)

### Listen to Order Status Changes

```dart
// In your OrderBloc or OrderRepository
Stream<Order> listenToOrderStatus(String orderId) {
  return FirebaseFirestore.instance
      .collection('orders')
      .doc(orderId)
      .snapshots()
      .map((doc) => Order.fromFirestore(doc));
}

// In your OrderBloc
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final FirebaseFirestore _firestore;

  OrderBloc(this._firestore) : super(OrderInitial()) {
    on<ListenToOrderStatus>((event, emit) async {
      await emit.forEach<Order>(
        listenToOrderStatus(event.orderId),
        onData: (order) {
          if (order.status == 'paid') {
            // Payment confirmed, navigate to success screen
            return OrderPaymentConfirmed(order);
          } else if (order.status == 'payment_failed') {
            // Payment failed, show error
            return OrderPaymentFailed(order);
          }
          return OrderLoaded(order);
        },
        onError: (error, stackTrace) => OrderError(error.toString()),
      );
    });
  }
}
```

### Real-time UI Updates

```dart
// In your order confirmation screen
class OrderConfirmationScreen extends StatelessWidget {
  final String orderId;

  const OrderConfirmationScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderBloc(context.read())
        ..add(ListenToOrderStatus(orderId)),
      child: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderPaymentConfirmed) {
            return PaymentSuccessWidget(order: state.order);
          } else if (state is OrderPaymentFailed) {
            return PaymentFailedWidget(order: state.order);
          } else if (state is OrderLoaded) {
            return OrderDetailsWidget(order: state.order);
          }
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}
```

### Push Notifications (Optional)

For better user experience, integrate Firebase Cloud Messaging to notify users of payment status changes:

```dart
// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data['type'] == 'payment_confirmed') {
    // Handle payment confirmation notification
    final orderId = message.data['order_id'];
    // Update local state or navigate to confirmation screen
  }
}

// In your main.dart
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

// Listen for foreground messages
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  if (message.data['type'] == 'payment_confirmed') {
    // Show in-app notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment confirmed for order ${message.data['order_id']}')),
    );
  }
});
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