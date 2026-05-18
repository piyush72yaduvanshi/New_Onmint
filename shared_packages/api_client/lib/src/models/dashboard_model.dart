class DashboardStats {
  final int? totalUsers;
  final int? totalBookings;
  final int? totalRevenue;
  final int? pendingApprovals;
  final int? activeBookings;
  final int? completedBookings;
  final int? totalAppointments;
  final int? todayAppointments; // NEW: For doctor dashboard
  final int? completedConsultations;
  final int? pendingRequests;
  final double? earnings;
  final double? rating;
  final int? totalRatings;
  final int? totalVisits;
  final int? activeVisits;
  final int? totalOrders;
  final int? activeOrders;
  final int? totalRides;
  final int? activeRides;
  final int? completedRides;
  final bool? isAvailable;
  final String? vehicleType;
  
  // Pharmacist specific fields
  final int? pendingOrders;
  final int? completedOrders;
  final int? totalMedicines;
  final int? lowStockItems;
  
  final Map<String, int>? serviceStats;
  final List<RecentActivity>? recentActivities;

  DashboardStats({
    this.totalUsers,
    this.totalBookings,
    this.totalRevenue,
    this.pendingApprovals,
    this.activeBookings,
    this.completedBookings,
    this.totalAppointments,
    this.todayAppointments,
    this.completedConsultations,
    this.pendingRequests,
    this.earnings,
    this.rating,
    this.totalRatings,
    this.totalVisits,
    this.activeVisits,
    this.totalOrders,
    this.activeOrders,
    this.totalRides,
    this.activeRides,
    this.completedRides,
    this.isAvailable,
    this.vehicleType,
    this.pendingOrders,
    this.completedOrders,
    this.totalMedicines,
    this.lowStockItems,
    this.serviceStats,
    this.recentActivities,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'],
      totalBookings: json['totalBookings'],
      totalRevenue: json['totalRevenue'],
      pendingApprovals: json['pendingApprovals'],
      activeBookings: json['activeBookings'],
      completedBookings: json['completedBookings'],
      totalAppointments: json['totalAppointments'] ?? json['todayAppointments'], // Support both
      todayAppointments: json['todayAppointments'],
      completedConsultations: json['completedConsultations'] ?? json['totalConsultations'],
      pendingRequests: json['pendingRequests'],
      earnings: json['earnings']?.toDouble(),
      rating: json['rating'] is Map ? json['rating']['average']?.toDouble() : json['rating']?.toDouble(),
      totalRatings: json['totalRatings'] ?? (json['rating'] is Map ? json['rating']['count'] : null),
      totalVisits: json['totalVisits'],
      activeVisits: json['activeVisits'],
      totalOrders: json['totalOrders'],
      activeOrders: json['activeOrders'],
      totalRides: json['totalRides'],
      activeRides: json['activeRides'],
      completedRides: json['completedRides'],
      isAvailable: json['isAvailable'],
      vehicleType: json['vehicleType'],
      pendingOrders: json['pendingOrders'],
      completedOrders: json['completedOrders'],
      totalMedicines: json['totalMedicines'],
      lowStockItems: json['lowStockItems'],
      serviceStats: json['serviceStats'] != null
          ? Map<String, int>.from(json['serviceStats'])
          : null,
      recentActivities: json['recentActivities'] != null
          ? (json['recentActivities'] as List)
              .map((e) => RecentActivity.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalBookings': totalBookings,
      'totalRevenue': totalRevenue,
      'pendingApprovals': pendingApprovals,
      'activeBookings': activeBookings,
      'completedBookings': completedBookings,
      'totalAppointments': totalAppointments,
      'todayAppointments': todayAppointments,
      'completedConsultations': completedConsultations,
      'pendingRequests': pendingRequests,
      'earnings': earnings,
      'rating': rating,
      'totalRatings': totalRatings,
      'totalVisits': totalVisits,
      'activeVisits': activeVisits,
      'totalOrders': totalOrders,
      'activeOrders': activeOrders,
      'totalRides': totalRides,
      'activeRides': activeRides,
      'completedRides': completedRides,
      'isAvailable': isAvailable,
      'vehicleType': vehicleType,
      'pendingOrders': pendingOrders,
      'completedOrders': completedOrders,
      'totalMedicines': totalMedicines,
      'lowStockItems': lowStockItems,
      'serviceStats': serviceStats,
      'recentActivities': recentActivities?.map((e) => e.toJson()).toList(),
    };
  }
}

class RecentActivity {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;

  RecentActivity({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
