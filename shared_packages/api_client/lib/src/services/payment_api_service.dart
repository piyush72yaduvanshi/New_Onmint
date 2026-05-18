import '../api_client_base.dart';

class PaymentApiService {
  final ApiClient _client;

  PaymentApiService(this._client);

  // Create Razorpay order
  Future<Map<String, dynamic>> createOrder(String bookingId) async {
    final response = await _client.post('/payments/create-order', data: {
      'bookingId': bookingId,
    });
    return response.data['data'];
  }

  // Verify payment
  Future<Map<String, dynamic>> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String bookingId,
  }) async {
    final response = await _client.post('/payments/verify', data: {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'bookingId': bookingId,
    }, headers: {
      'idempotency-key': 'payment_${bookingId}_${DateTime.now().millisecondsSinceEpoch}',
    });
    return response.data['data'];
  }

  // Get payment details
  Future<Map<String, dynamic>> getPaymentDetails(String bookingId) async {
    final response = await _client.get('/payments/$bookingId');
    return response.data['data'];
  }

  // Setup vendor bank details
  Future<void> setupBankDetails({
    required String accountHolderName,
    required String accountNumber,
    required String ifsc,
  }) async {
    await _client.post('/payments/vendor/bank-details', data: {
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'ifsc': ifsc,
    });
  }

  // Release payout (Admin only)
  Future<void> releasePayout(String bookingId) async {
    await _client.post('/payments/release-payout', data: {
      'bookingId': bookingId,
    });
  }
}
