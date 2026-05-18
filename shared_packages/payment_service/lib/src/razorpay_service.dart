import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'payment_models.dart';

class RazorpayService {
  static final RazorpayService _instance = RazorpayService._internal();
  factory RazorpayService() => _instance;
  RazorpayService._internal();

  late Razorpay _razorpay;
  Function(PaymentResponse)? _onPaymentComplete;

  // Razorpay API Keys (Replace with your actual keys in production)
  static const String _keyId = 'rzp_test_YOUR_KEY_ID'; // Replace with your key
  static const String _keySecret = 'YOUR_KEY_SECRET'; // Replace with your secret

  void initialize() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void dispose() {
    _razorpay.clear();
  }

  Future<void> openCheckout({
    required PaymentRequest request,
    required Function(PaymentResponse) onComplete,
  }) async {
    _onPaymentComplete = onComplete;

    var options = {
      'key': _keyId,
      'amount': (request.amount * 100).toInt(), // Amount in paise
      'currency': request.currency,
      'name': 'OnMint Healthcare',
      'description': request.description,
      'order_id': request.orderId,
      'prefill': {
        'contact': request.phone ?? '',
        'email': request.email ?? '',
      },
      'theme': {
        'color': '#00BCD4',
      },
      'modal': {
        'ondismiss': () {
          _onPaymentComplete?.call(
            PaymentResponse.failure('Payment cancelled by user'),
          );
        }
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      _onPaymentComplete?.call(
        PaymentResponse.failure('Error opening payment: ${e.toString()}'),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _onPaymentComplete?.call(
      PaymentResponse.success(
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _onPaymentComplete?.call(
      PaymentResponse.failure(
        response.message ?? 'Payment failed',
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _onPaymentComplete?.call(
      PaymentResponse.failure(
        'External wallet selected: ${response.walletName}',
      ),
    );
  }
}
