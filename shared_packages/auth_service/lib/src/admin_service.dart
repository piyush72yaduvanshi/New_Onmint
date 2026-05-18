import 'package:api_client/api_client.dart';

/// Admin service for OnMint healthcare platform
class AdminService {
  final ApiClient _apiClient = ApiClient();

  /// Get pending approvals
  Future<ApiResponse<List<Map<String, dynamic>>>> getPendingApprovals() async {
    try {
      print('Making authenticated API call to get pending approvals');
      
      final response = await _apiClient.get<List<Map<String, dynamic>>>(
        '/admin/approvals/pending',
        fromJson: (json) {
          print('Raw pending approvals response: $json');
          
          if (json is Map<String, dynamic>) {
            // FIRST: Handle nested structure: {success: true, data: {users: [...], total: 15}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              final data = json['data'] as Map<String, dynamic>;
              if (data['users'] is List) {
                final approvals = (data['users'] as List).cast<Map<String, dynamic>>();
                print('Extracted ${approvals.length} pending approvals from nested structure: success.data.users');
                return approvals;
              }
            }
            // SECOND: Handle direct response format: {users: [...], total: 15}
            else if (json['users'] is List) {
              final approvals = (json['users'] as List).cast<Map<String, dynamic>>();
              print('Extracted ${approvals.length} pending approvals from direct users array');
              return approvals;
            }
            // THIRD: Handle direct array: {success: true, data: [...]}
            else if (json['data'] is List) {
              final approvals = (json['data'] as List).cast<Map<String, dynamic>>();
              print('Extracted ${approvals.length} pending approvals from direct structure');
              return approvals;
            }
          }
          print('No pending approvals found in response structure');
          return <Map<String, dynamic>>[];
        },
      );
      
      print('Pending approvals response: Success=${response.success}, StatusCode=${response.statusCode}');
      if (!response.success) {
        print('Error details: ${response.error?.message}');
      }
      return response;
    } catch (e) {
      print('Get pending approvals API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'PENDING_APPROVALS_ERROR',
          message: 'Failed to fetch pending approvals: $e',
        ),
      );
    }
  }

  /// Get dashboard stats
  Future<ApiResponse<Map<String, dynamic>>> getDashboardStats() async {
    try {
      print('Making authenticated API call to get dashboard stats');
      
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/admin/dashboard',
        fromJson: (json) {
          print('Raw dashboard stats response: $json');
          
          if (json is Map<String, dynamic>) {
            // FIRST: Handle nested structure: {success: true, data: {totalUsers: 15, ...}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              final data = json['data'] as Map<String, dynamic>;
              print('Extracted dashboard stats from nested structure: success.data');
              return data;
            }
            // SECOND: Handle direct structure where the entire response is the data
            else if (json.containsKey('totalUsers') || json.containsKey('activeBookings')) {
              print('Extracted dashboard stats from direct structure');
              return json;
            }
          }
          print('Dashboard stats structure not recognized, returning as-is');
          return json as Map<String, dynamic>;
        },
      );
      
      print('Dashboard stats response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('Get dashboard stats API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'DASHBOARD_STATS_ERROR',
          message: 'Failed to fetch dashboard stats: $e',
        ),
      );
    }
  }

  /// Test API connection and authentication
  Future<ApiResponse<Map<String, dynamic>>> testApiConnection() async {
    try {
      print('🧪 TEST: Testing API connection and authentication');
      
      // Test with no filters first
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/admin/users',
        fromJson: (json) {
          print('🧪 TEST: Raw response: $json');
          return json as Map<String, dynamic>;
        },
      );
      
      print('🧪 TEST: Connection test result - Success: ${response.success}, Status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('🧪 TEST: Connection test failed: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'CONNECTION_TEST_ERROR',
          message: 'Connection test failed: $e',
        ),
      );
    }
  }

  /// Get all users with filters
  Future<ApiResponse<List<Map<String, dynamic>>>> getAllUsers({
    String? role,
    String? status,
  }) async {
    try {
      print('🔍 DEBUG: Making authenticated API call to get all users');
      print('🔍 DEBUG: Filters - Role: $role, Status: $status');
      
      final queryParams = <String, String>{};
      if (role != null && role.isNotEmpty) queryParams['role'] = role;
      
      // Handle "approved" filter to include both approved and active users
      if (status != null && status.isNotEmpty) {
        if (status == 'approved') {
          // For approved filter, we'll get all users and filter client-side
          // since API might not support multiple status values
          print('🔍 DEBUG: Approved filter selected - will include both approved and active users');
        } else {
          queryParams['status'] = status;
        }
      }
      
      print('🔍 DEBUG: Query params: $queryParams');
      print('🔍 DEBUG: Final endpoint: /admin/users${queryParams.isNotEmpty ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}' : ''}');
      
      final response = await _apiClient.get<List<Map<String, dynamic>>>(
        '/admin/users',
        queryParams: queryParams,
        fromJson: (json) {
          print('🔍 DEBUG: Raw API response received');
          print('🔍 DEBUG: Response type: ${json.runtimeType}');
          print('🔍 DEBUG: Response content: $json');
          
          if (json is Map<String, dynamic>) {
            print('🔍 DEBUG: Response is Map, checking structure...');
            print('🔍 DEBUG: Keys: ${json.keys.toList()}');
            
            // FIRST: Handle direct response format: {users: [...], total: 15, page: 1, limit: 20}
            if (json['users'] is List) {
              var users = (json['users'] as List).cast<Map<String, dynamic>>();
              print('✅ SUCCESS: Extracted ${users.length} users from direct users array');
              
              // Apply client-side filtering for "approved" status
              if (status == 'approved') {
                users = users.where((user) {
                  final userStatus = user['status']?.toString() ?? '';
                  return userStatus == 'approved' || userStatus == 'active';
                }).toList();
                print('🔍 DEBUG: After approved filter: ${users.length} users (approved + active)');
              }
              
              if (users.isNotEmpty) {
                print('🔍 DEBUG: Sample user: ${users.first}');
              }
              return users;
            }
            
            print('❌ DEBUG: No users array found in direct format');
            print('🔍 DEBUG: Checking for nested structures...');
            
            // SECOND: Handle nested structure: {success: true, data: {users: [...], total: 3}}
            if (json.containsKey('success') && json['success'] == true && json['data'] is Map<String, dynamic>) {
              final data = json['data'] as Map<String, dynamic>;
              print('🔍 DEBUG: Found nested success.data structure');
              
              if (data['users'] is List) {
                var users = (data['users'] as List).cast<Map<String, dynamic>>();
                print('✅ SUCCESS: Extracted ${users.length} users from nested structure: success.data.users');
                
                // Apply client-side filtering for "approved" status
                if (status == 'approved') {
                  users = users.where((user) {
                    final userStatus = user['status']?.toString() ?? '';
                    return userStatus == 'approved' || userStatus == 'active';
                  }).toList();
                  print('🔍 DEBUG: After approved filter: ${users.length} users (approved + active)');
                }
                
                if (users.isNotEmpty) {
                  print('🔍 DEBUG: Sample user: ${users.first}');
                }
                return users;
              }
            }
            
            // Handle other possible structures...
            if (json.containsKey('data')) {
              print('🔍 DEBUG: Found data key, type: ${json['data'].runtimeType}');
              print('🔍 DEBUG: Data content: ${json['data']}');
            }
          }
          
          print('❌ FAILED: Could not extract users from response');
          return <Map<String, dynamic>>[];
        },
      );
      
      print('🔍 DEBUG: API call completed');
      print('🔍 DEBUG: Response success: ${response.success}');
      print('🔍 DEBUG: Response status code: ${response.statusCode}');
      print('🔍 DEBUG: Response data length: ${response.data?.length ?? 0}');
      
      if (!response.success) {
        print('❌ DEBUG: API call failed - ${response.error?.message}');
      }
      
      return response;
    } catch (e) {
      print('❌ DEBUG: Exception in getAllUsers: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'ALL_USERS_ERROR',
          message: 'Failed to fetch users: $e',
        ),
      );
    }
  }

  /// Approve provider
  Future<ApiResponse<Map<String, dynamic>>> approveProvider(String userId) async {
    try {
      print('Making API call to approve provider: $userId');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/admin/providers/$userId/approve',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      
      print('Approve provider response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('Approve provider API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'APPROVE_PROVIDER_ERROR',
          message: 'Failed to approve provider: $e',
        ),
      );
    }
  }

  /// Reject provider
  Future<ApiResponse<Map<String, dynamic>>> rejectProvider(String userId, String reason) async {
    try {
      print('Making API call to reject provider: $userId');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/admin/providers/$userId/reject',
        body: {'reason': reason},
        fromJson: (json) => json as Map<String, dynamic>,
      );
      
      print('Reject provider response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('Reject provider API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'REJECT_PROVIDER_ERROR',
          message: 'Failed to reject provider: $e',
        ),
      );
    }
  }

  /// Block user
  Future<ApiResponse<Map<String, dynamic>>> blockUser(String userId) async {
    try {
      print('Making API call to block user: $userId');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/admin/users/$userId/block',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      
      print('Block user response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('Block user API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'BLOCK_USER_ERROR',
          message: 'Failed to block user: $e',
        ),
      );
    }
  }

  /// Unblock user
  Future<ApiResponse<Map<String, dynamic>>> unblockUser(String userId) async {
    try {
      print('Making API call to unblock user: $userId');
      
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/admin/users/$userId/unblock',
        fromJson: (json) => json as Map<String, dynamic>,
      );
      
      print('Unblock user response: Success=${response.success}, StatusCode=${response.statusCode}');
      return response;
    } catch (e) {
      print('Unblock user API error: $e');
      return ApiResponse.error(
        error: ApiError(
          code: 'UNBLOCK_USER_ERROR',
          message: 'Failed to unblock user: $e',
        ),
      );
    }
  }
}