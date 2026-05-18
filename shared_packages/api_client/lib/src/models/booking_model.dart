import 'user_model.dart';

class Booking {
  final String id;
  final String patient;
  final String provider;
  final User? patientDetails;
  final User? providerDetails;
  final String serviceType;
  final String status;
  final DateTime scheduledTime;
  final BookingLocation location;
  final TimeSlot? timeSlot;
  final String? notes;
  final double price;
  final Rating? rating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final bool isEmergency;

  Booking({
    required this.id,
    required this.patient,
    required this.provider,
    this.patientDetails,
    this.providerDetails,
    required this.serviceType,
    required this.status,
    required this.scheduledTime,
    required this.location,
    this.timeSlot,
    this.notes,
    required this.price,
    this.rating,
    required this.createdAt,
    required this.updatedAt,
    this.cancellationReason,
    this.cancelledAt,
    this.isEmergency = false,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id'] ?? json['id'] ?? '',
      patient: json['patient'] is String ? json['patient'] : json['patient']?['_id'] ?? '',
      provider: json['provider'] is String ? json['provider'] : json['provider']?['_id'] ?? '',
      patientDetails: json['patient'] is Map ? User.fromJson(json['patient']) : null,
      providerDetails: json['provider'] is Map ? User.fromJson(json['provider']) : null,
      serviceType: json['serviceType'] ?? '',
      status: json['status'] ?? '',
      scheduledTime: DateTime.parse(json['scheduledTime'] ?? DateTime.now().toIso8601String()),
      location: BookingLocation.fromJson(json['location'] ?? {}),
      timeSlot: json['timeSlot'] != null ? TimeSlot.fromJson(json['timeSlot']) : null,
      notes: json['notes'],
      price: (json['price'] ?? 0).toDouble(),
      rating: json['rating'] != null ? Rating.fromJson(json['rating']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      cancellationReason: json['cancellationReason'],
      cancelledAt: json['cancelledAt'] != null ? DateTime.parse(json['cancelledAt']) : null,
      isEmergency: json['isEmergency'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient': patient,
      'provider': provider,
      'serviceType': serviceType,
      'scheduledTime': scheduledTime.toIso8601String(),
      'location': location.toJson(),
      if (timeSlot != null) 'timeSlot': timeSlot!.toJson(),
      if (notes != null) 'notes': notes,
      'price': price,
    };
  }

  bool get isActive => ['requested', 'accepted', 'on_the_way', 'in_progress'].contains(status);
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get canBeCancelled => ['requested', 'accepted'].contains(status);
  bool get canBeRated => status == 'completed' && rating == null;
}

class BookingLocation {
  final String? address;
  final List<double>? coordinates;

  BookingLocation({
    this.address,
    this.coordinates,
  });

  factory BookingLocation.fromJson(Map<String, dynamic> json) {
    return BookingLocation(
      address: json['address'],
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (address != null) 'address': address,
      if (coordinates != null) 'coordinates': coordinates,
    };
  }

  double? get longitude => coordinates != null && coordinates!.isNotEmpty ? coordinates![0] : null;
  double? get latitude => coordinates != null && coordinates!.length > 1 ? coordinates![1] : null;
}

class Rating {
  final int rating;
  final String? review;
  final DateTime? createdAt;

  Rating({
    required this.rating,
    this.review,
    this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rating: json['rating'] ?? 0,
      review: json['review'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      if (review != null) 'review': review,
    };
  }
}
