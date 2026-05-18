import '../api_client_base.dart';

/// Rating and Review API service
class RatingApiService {
  final ApiClient _client;

  RatingApiService(this._client);

  /// Submit a rating and review
  Future<Map<String, dynamic>> submitRating({
    required String bookingId,
    required String providerId,
    required String providerType,
    required int rating,
    String? review,
  }) async {
    final response = await _client.post('/ratings', data: {
      'bookingId': bookingId,
      'providerId': providerId,
      'providerType': providerType,
      'rating': rating,
      if (review != null && review.isNotEmpty) 'review': review,
    });

    return response.data['data'];
  }

  /// Get ratings for a provider
  Future<Map<String, dynamic>> getProviderRatings({
    required String providerId,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      '/ratings/provider/$providerId',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return response.data['data'];
  }

  /// Get user's ratings
  Future<Map<String, dynamic>> getUserRatings({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.get(
      '/ratings/user',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return response.data['data'];
  }

  /// Get rating for a specific booking
  Future<Map<String, dynamic>?> getBookingRating(String bookingId) async {
    try {
      final response = await _client.get('/ratings/booking/$bookingId');
      return response.data['data'];
    } catch (e) {
      return null; // No rating yet
    }
  }

  /// Update a rating
  Future<Map<String, dynamic>> updateRating({
    required String ratingId,
    required int rating,
    String? review,
  }) async {
    final response = await _client.put('/ratings/$ratingId', data: {
      'rating': rating,
      if (review != null) 'review': review,
    });

    return response.data['data'];
  }

  /// Delete a rating
  Future<void> deleteRating(String ratingId) async {
    await _client.delete('/ratings/$ratingId');
  }

  /// Get provider rating summary
  Future<Map<String, dynamic>> getProviderRatingSummary(String providerId) async {
    final response = await _client.get('/ratings/provider/$providerId/summary');
    return response.data['data'];
  }

  /// Report a review
  Future<void> reportReview({
    required String ratingId,
    required String reason,
  }) async {
    await _client.post('/ratings/$ratingId/report', data: {
      'reason': reason,
    });
  }
}
