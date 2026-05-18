class PaymentRequest {
  final String orderId;
  final double amount;
  final String currency;
  final String name;
  final String description;
  final String? email;
  final String? phone;

  PaymentRequest({
    required this.orderId,
    required this.amount,
    this.currency = 'INR',
    required this.name,
    required this.description,
    this.email,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'name': name,
      'description': description,
      'email': email,
      'phone': phone,
    };
  }
}

class PaymentResponse {
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final bool success;
  final String? error;

  PaymentResponse({
    this.paymentId,
    this.orderId,
    this.signature,
    required this.success,
    this.error,
  });

  factory PaymentResponse.success({
    required String paymentId,
    required String orderId,
    required String signature,
  }) {
    return PaymentResponse(
      paymentId: paymentId,
      orderId: orderId,
      signature: signature,
      success: true,
    );
  }

  factory PaymentResponse.failure(String error) {
    return PaymentResponse(
      success: false,
      error: error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'orderId': orderId,
      'signature': signature,
      'success': success,
      'error': error,
    };
  }
}
