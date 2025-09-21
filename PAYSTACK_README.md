# 💳 Paystack Setup Guide for E-Commerce Flutter App

This guide walks you through setting up Paystack payment processing for your Flutter e-commerce app. Follow each step carefully!

## 📋 What You'll Need

- ✅ Paystack account (create at https://paystack.com)
- ✅ Your Flutter app code (already includes Paystack integration)
- ✅ Test device or emulator for testing payments

---

## 🏦 Step 1: Create Paystack Account

1. **Visit Paystack**: Go to https://paystack.com/
2. **Sign Up**: Click the "Sign Up" button
3. **Choose Account Type**:
   - Select "Individual" for personal use
   - Select "Business" for company use
4. **Fill Registration Form**:
   - Enter your email, password, and business details
   - Complete phone verification
5. **Verify Email**: Check your email and click the verification link
6. **Complete Profile**: Fill in your business information and bank details

---

## ⚙️ Step 2: Get Your API Keys (VERY IMPORTANT!)

1. **Login to Dashboard**: Go to https://dashboard.paystack.com/
2. **Navigate to Settings**: Click "Settings" in the left menu
3. **API Keys & Webhooks**: Click "API Keys & Webhooks"
4. **Copy Keys**: You'll see two sets of keys:

### Test Keys (for development)
- **Public Key**: Starts with `pk_test_` (safe to use in app code)
- **Secret Key**: Starts with `sk_test_` (keep secret!)

### Live Keys (for production)
- **Public Key**: Starts with `pk_live_`
- **Secret Key**: Starts with `sk_live_`

**🔒 SECURITY WARNING**: Never share your secret keys! Only the public key goes in your app.

---

## 🔧 Step 3: Configure Paystack in Your Flutter App

### Method 1: Direct Code Update (Quick for testing)

1. **Open Checkout Screen**: Open file `lib/screens/checkout_screen.dart`
2. **Find Paystack Initialization**: Look for this line (around line 467):
   ```dart
   plugin.initialize(publicKey: 'pk_test_your_paystack_public_key_here');
   ```
3. **Replace with your key**:
   ```dart
   plugin.initialize(publicKey: 'pk_test_xxxxxxxxxxxxxxxxxx'); // Your test public key
   ```

### Method 2: Environment Variables (Recommended for production)

1. **Create environment file**: Create `.env` in your project root:
   ```
   PAYSTACK_PUBLIC_KEY_TEST=pk_test_your_test_key_here
   PAYSTACK_PUBLIC_KEY_LIVE=pk_live_your_live_key_here
   ```

2. **Add to .gitignore**: Make sure `.env` is in your `.gitignore` file

3. **Install flutter_dotenv package**:
   ```bash
   flutter pub add flutter_dotenv
   ```

4. **Update checkout_screen.dart**:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   // In initState:
   plugin.initialize(publicKey: dotenv.env['PAYSTACK_PUBLIC_KEY_TEST']!);
   ```

---

## 🧪 Step 4: Test Your Payment Setup

### Test Card Numbers (Provided by Paystack)

Use these cards for testing - they work with any future expiry date and any 3-digit CVV:

| Card Number | Result |
|-------------|--------|
| `4084084084084081` | ✅ **Success** |
| `4084084084084082` | ❌ **Declined** |
| `4084084084084083` | ❌ **Insufficient Funds** |
| `4084084084084084` | ❌ **Lost Card** |

### How to Test

1. **Run your app**: `flutter run`
2. **Add items to cart**: Add some products
3. **Go to checkout**: Select "Paystack" as payment method
4. **Enter test card**: Use `4084084084084081`
5. **Complete payment**: Should succeed
6. **Check Paystack Dashboard**: Go to Transactions → see your test payment

---

## 🌐 Step 5: Set Up Webhooks (Important for Production)

Webhooks notify your app when payments complete. Since you're using Firebase, see [WEBHOOK_SETUP_README.md](WEBHOOK_SETUP_README.md) for detailed setup.

### Quick Webhook Setup

1. **In Paystack Dashboard**: Settings → API Keys & Webhooks
2. **Add Webhook**: Click "Add Webhook"
3. **URL**: Your Firebase Cloud Function URL (from webhook setup)
4. **Events**: Select these events:
   - `charge.success`
   - `charge.failed`
   - `transfer.success`
   - `transfer.failed`
5. **Save**: Click "Save"

---

## 🚀 Step 6: Go Live (Production Setup)

**⚠️ WARNING**: Only do this when your app is ready for real customers!

### Switch to Live Keys

1. **Update your app code**: Replace test key with live key
2. **Update webhook URL**: Change from test to production webhook URL
3. **Test with real card**: Use a real debit/credit card (small amount)
4. **Verify in dashboard**: Check Paystack dashboard for real transactions

### Production Checklist

- ✅ Live API keys configured
- ✅ Live webhook URL set
- ✅ Business profile completed
- ✅ Bank account linked
- ✅ Terms accepted
- ✅ Account approved by Paystack

---

## 🔒 Security Best Practices

### API Keys
- **Never commit secret keys** to version control
- **Use environment variables** for different environments
- **Rotate keys regularly** in production

### Webhook Security
- **Verify webhook signatures** (covered in webhook setup)
- **Use HTTPS URLs only**
- **Validate event data** before processing

### Payment Data
- **Don't store card details** in your database
- **Use Paystack's secure checkout** for all payments
- **Validate amounts** before processing

---

## 📊 Step 7: Monitor Your Payments

1. **Paystack Dashboard**: Check transactions, refunds, and settlements
2. **Set up notifications**: Get email alerts for payment events
3. **Monitor failed payments**: Identify and fix payment issues
4. **Review settlements**: Track when money arrives in your bank

---

## 🚨 Troubleshooting

### "Invalid API Key" Error
- Check that you're using the correct public key
- Make sure there are no extra spaces
- Verify the key starts with `pk_test_` or `pk_live_`

### Payment Popup Doesn't Open
- Ensure Paystack plugin is initialized in `initState`
- Check that `context` is available (not called during build)
- Verify internet connection

### Webhook Not Working
- Confirm webhook URL is accessible
- Check that your server responds with 200 OK
- Verify webhook signature validation

### Test Payments Not Appearing
- Use test keys for test mode
- Check Paystack dashboard → Transactions
- Make sure you're using test card numbers

---

## 💰 Supported Payment Methods

Paystack supports many payment options. Your app currently uses card payments, but you can add:

- **Bank Transfers**: Direct bank account payments
- **Mobile Money**: MTN, Airtel, etc. (Nigeria, Ghana, etc.)
- **USSD**: *737* or similar codes
- **QR Codes**: For quick payments
- **PayPal**: International payments

To add more methods, update `lib/screens/checkout_screen.dart` payment options.

---

## 📞 Support

- **Paystack Documentation**: https://developers.paystack.co/docs
- **Paystack Support**: support@paystack.com
- **Community**: Join Paystack developer communities

---

## 🎯 Next Steps

1. ✅ Complete Firebase setup
2. ✅ Set up Paystack (you're here!)
3. 🔄 Set up webhooks (see WEBHOOK_SETUP_README.md)
4. 🚀 Test thoroughly before going live

Your Paystack payment setup is now complete! 🎉