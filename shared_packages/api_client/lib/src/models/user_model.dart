class User {
  final String id;
  final String email;
  final String phone;
  final String? firstName;
  final String? lastName;
  final String role;
  final String status;
  final Address? address;
  final Location? location;
  final String? deviceToken;
  final String? profilePicture;
  final String? profilePictureUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Patient-specific fields
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodGroup;
  
  // Emergency Contact
  final Map<String, dynamic>? emergencyContact;
  
  // Role-specific fields
  final String? specialization; // Doctor
  final List<String>? qualifications; // Doctor
  final int? experience; // Doctor, Nurse
  final double? consultationFee; // Doctor
  final List<String>? languages; // Doctor
  final String? about; // Doctor
  final String? licenseNumber; // Doctor, Nurse, Pharmacist, Ambulance
  
  // Nurse specific
  final List<String>? specializations; // Nurse
  final List<String>? certifications; // Nurse
  final List<ServiceOffered>? servicesOffered; // Nurse
  
  // Pharmacist specific
  final String? pharmacyName; // Pharmacist
  final List<String>? deliveryTimes; // Pharmacist
  final double? minimumOrderAmount; // Pharmacist
  final double? deliveryFee; // Pharmacist
  final OperatingHours? operatingHours; // Pharmacist
  
  // Ambulance specific
  final String? driverName; // Ambulance
  final String? driverLicense; // Ambulance
  final String? vehicleNumber; // Ambulance
  final String? vehicleType; // Ambulance
  final List<String>? equipmentAvailable; // Ambulance
  final bool? isAvailable; // Ambulance
  final Location? currentLocation; // Ambulance
  
  // Blood Bank specific
  final List<BloodStock>? bloodStock; // Blood Bank
  
  // Pathology specific
  final List<PathologyTest>? testsOffered; // Pathology
  
  // Availability
  final List<Availability>? availability;
  
  // Ratings
  final double? rating;
  final int? totalRatings;
  
  // Distance (calculated field from backend when searching with location)
  final double? distance;

  User({
    required this.id,
    required this.email,
    required this.phone,
    this.firstName,
    this.lastName,
    required this.role,
    required this.status,
    this.address,
    this.location,
    this.deviceToken,
    this.profilePicture,
    this.profilePictureUrl,
    required this.createdAt,
    required this.updatedAt,
    this.dateOfBirth,
    this.gender,
    this.bloodGroup,
    this.emergencyContact,
    this.specialization,
    this.qualifications,
    this.experience,
    this.consultationFee,
    this.languages,
    this.about,
    this.licenseNumber,
    this.specializations,
    this.certifications,
    this.servicesOffered,
    this.pharmacyName,
    this.deliveryTimes,
    this.minimumOrderAmount,
    this.deliveryFee,
    this.operatingHours,
    this.driverName,
    this.driverLicense,
    this.vehicleNumber,
    this.vehicleType,
    this.equipmentAvailable,
    this.isAvailable,
    this.currentLocation,
    this.bloodStock,
    this.testsOffered,
    this.availability,
    this.rating,
    this.totalRatings,
    this.distance,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      deviceToken: json['deviceToken'],
      profilePicture: json['profilePicture'],
      profilePictureUrl: json['profilePictureUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      dateOfBirth: json['dateOfBirth'] != null ? DateTime.parse(json['dateOfBirth']) : null,
      gender: json['gender'],
      bloodGroup: json['bloodGroup'],
      emergencyContact: json['emergencyContact'],
      specialization: json['specialization'],
      qualifications: json['qualifications'] != null ? List<String>.from(json['qualifications']) : null,
      experience: json['experience'],
      consultationFee: json['consultationFee']?.toDouble(),
      languages: json['languages'] != null ? List<String>.from(json['languages']) : null,
      about: json['about'],
      licenseNumber: json['licenseNumber'],
      specializations: json['specializations'] != null ? List<String>.from(json['specializations']) : null,
      certifications: json['certifications'] != null ? List<String>.from(json['certifications']) : null,
      servicesOffered: json['servicesOffered'] != null
          ? (json['servicesOffered'] as List).map((e) => ServiceOffered.fromJson(e)).toList()
          : null,
      pharmacyName: json['pharmacyName'],
      deliveryTimes: json['deliveryTimes'] != null ? List<String>.from(json['deliveryTimes']) : null,
      minimumOrderAmount: json['minimumOrderAmount']?.toDouble(),
      deliveryFee: json['deliveryFee']?.toDouble(),
      operatingHours: json['operatingHours'] != null ? OperatingHours.fromJson(json['operatingHours']) : null,
      driverName: json['driverName'],
      driverLicense: json['driverLicense'],
      vehicleNumber: json['vehicleNumber'],
      vehicleType: json['vehicleType'],
      equipmentAvailable: json['equipmentAvailable'] != null ? List<String>.from(json['equipmentAvailable']) : null,
      isAvailable: json['isAvailable'],
      currentLocation: json['currentLocation'] != null ? Location.fromJson(json['currentLocation']) : null,
      bloodStock: json['bloodStock'] != null
          ? (json['bloodStock'] as List).map((e) => BloodStock.fromJson(e)).toList()
          : null,
      testsOffered: json['testsOffered'] != null
          ? (json['testsOffered'] as List).map((e) => PathologyTest.fromJson(e)).toList()
          : null,
      availability: json['availability'] != null
          ? (json['availability'] as List).map((e) => Availability.fromJson(e)).toList()
          : null,
      rating: json['rating']?.toDouble(),
      totalRatings: json['totalRatings'],
      distance: json['distance']?.toDouble(), // NEW: Distance field from backend
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'phone': phone,
      'role': role,
    };
    
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (address != null) data['address'] = address!.toJson();
    if (location != null) data['location'] = location!.toJson();
    if (deviceToken != null) data['deviceToken'] = deviceToken;
    if (profilePicture != null) data['profilePicture'] = profilePicture;
    if (profilePictureUrl != null) data['profilePictureUrl'] = profilePictureUrl;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth!.toIso8601String();
    if (gender != null) data['gender'] = gender;
    if (bloodGroup != null) data['bloodGroup'] = bloodGroup;
    if (emergencyContact != null) data['emergencyContact'] = emergencyContact;
    if (specialization != null) data['specialization'] = specialization;
    if (qualifications != null) data['qualifications'] = qualifications;
    if (experience != null) data['experience'] = experience;
    if (consultationFee != null) data['consultationFee'] = consultationFee;
    if (languages != null) data['languages'] = languages;
    if (about != null) data['about'] = about;
    if (licenseNumber != null) data['licenseNumber'] = licenseNumber;
    if (specializations != null) data['specializations'] = specializations;
    if (certifications != null) data['certifications'] = certifications;
    if (servicesOffered != null) data['servicesOffered'] = servicesOffered!.map((e) => e.toJson()).toList();
    if (pharmacyName != null) data['pharmacyName'] = pharmacyName;
    if (deliveryTimes != null) data['deliveryTimes'] = deliveryTimes;
    if (minimumOrderAmount != null) data['minimumOrderAmount'] = minimumOrderAmount;
    if (deliveryFee != null) data['deliveryFee'] = deliveryFee;
    if (operatingHours != null) data['operatingHours'] = operatingHours!.toJson();
    if (driverName != null) data['driverName'] = driverName;
    if (driverLicense != null) data['driverLicense'] = driverLicense;
    if (vehicleNumber != null) data['vehicleNumber'] = vehicleNumber;
    if (vehicleType != null) data['vehicleType'] = vehicleType;
    if (equipmentAvailable != null) data['equipmentAvailable'] = equipmentAvailable;
    if (isAvailable != null) data['isAvailable'] = isAvailable;
    if (currentLocation != null) data['currentLocation'] = currentLocation!.toJson();
    if (bloodStock != null) data['bloodStock'] = bloodStock!.map((e) => e.toJson()).toList();
    if (testsOffered != null) data['testsOffered'] = testsOffered!.map((e) => e.toJson()).toList();
    if (availability != null) data['availability'] = availability!.map((e) => e.toJson()).toList();
    
    return data;
  }

  String get fullName => '${firstName ?? ''} ${lastName ?? ''}'.trim();
  
  String get city => address?.city ?? '';
  String get state => address?.state ?? '';
  String get pincode => address?.pincode ?? '';
  
  // Role-based getters
  bool get isPatient => role == 'patient';
  bool get isVendor => ['doctor', 'pharmacist', 'nurse', 'ambulance', 'bloodbank', 'pathology'].contains(role);
  bool get isAdmin => role == 'admin';
}

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? pincode;
  final String? zipCode;
  final String? country;

  Address({
    this.street,
    this.city,
    this.state,
    this.pincode,
    this.zipCode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      zipCode: json['zipCode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (pincode != null) 'pincode': pincode,
      if (zipCode != null) 'zipCode': zipCode,
      if (country != null) 'country': country,
    };
  }

  String get fullAddress {
    final parts = [street, city, state, pincode ?? zipCode, country]
        .where((part) => part != null && part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}

class Location {
  final String type;
  final List<double> coordinates;
  final DateTime? lastUpdated;

  Location({
    this.type = 'Point',
    required this.coordinates,
    this.lastUpdated,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(json['coordinates'].map((x) => x.toDouble()))
          : [0.0, 0.0],
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      if (lastUpdated != null) 'lastUpdated': lastUpdated!.toIso8601String(),
    };
  }

  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
  double get latitude => coordinates.length > 1 ? coordinates[1] : 0.0;
}

class ServiceOffered {
  final String name;
  final String description;
  final double pricePerHour;

  ServiceOffered({
    required this.name,
    required this.description,
    required this.pricePerHour,
  });

  factory ServiceOffered.fromJson(Map<String, dynamic> json) {
    return ServiceOffered(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'pricePerHour': pricePerHour,
    };
  }
}

class OperatingHours {
  final String open;
  final String close;

  OperatingHours({
    required this.open,
    required this.close,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      open: json['open'] ?? '',
      close: json['close'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': open,
      'close': close,
    };
  }
}

class BloodStock {
  final String bloodGroup;
  final int unitsAvailable;

  BloodStock({
    required this.bloodGroup,
    required this.unitsAvailable,
  });

  factory BloodStock.fromJson(Map<String, dynamic> json) {
    return BloodStock(
      bloodGroup: json['bloodGroup'] ?? '',
      unitsAvailable: json['unitsAvailable'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bloodGroup': bloodGroup,
      'unitsAvailable': unitsAvailable,
    };
  }
}

class PathologyTest {
  final String name;
  final String description;
  final double price;
  final String? preparationInstructions;
  final String? reportDeliveryTime;

  PathologyTest({
    required this.name,
    required this.description,
    required this.price,
    this.preparationInstructions,
    this.reportDeliveryTime,
  });

  factory PathologyTest.fromJson(Map<String, dynamic> json) {
    return PathologyTest(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      preparationInstructions: json['preparationInstructions'],
      reportDeliveryTime: json['reportDeliveryTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      if (preparationInstructions != null) 'preparationInstructions': preparationInstructions,
      if (reportDeliveryTime != null) 'reportDeliveryTime': reportDeliveryTime,
    };
  }
}

class Availability {
  final String? day; // For doctor (MONDAY, TUESDAY, etc.)
  final DateTime? date; // For nurse (specific date)
  final String? startTime;
  final String? endTime;
  final bool? isAvailable;
  final bool? isBooked;
  final List<TimeSlot>? slots; // For doctor

  Availability({
    this.day,
    this.date,
    this.startTime,
    this.endTime,
    this.isAvailable,
    this.isBooked,
    this.slots,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      day: json['day'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      startTime: json['startTime'],
      endTime: json['endTime'],
      isAvailable: json['isAvailable'],
      isBooked: json['isBooked'],
      slots: json['slots'] != null
          ? (json['slots'] as List).map((e) => TimeSlot.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (day != null) 'day': day,
      if (date != null) 'date': date!.toIso8601String(),
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (isAvailable != null) 'isAvailable': isAvailable,
      if (isBooked != null) 'isBooked': isBooked,
      if (slots != null) 'slots': slots!.map((e) => e.toJson()).toList(),
    };
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      isAvailable: json['isAvailable'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }
}
