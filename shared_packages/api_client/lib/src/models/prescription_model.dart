import 'user_model.dart';

class Prescription {
  final String id;
  final String patient;
  final String doctor;
  final String? booking;
  final User? patientDetails;
  final User? doctorDetails;
  final String diagnosis;
  final List<Medication> medications;
  final List<String>? tests;
  final String? notes;
  final DateTime? followUpDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Prescription({
    required this.id,
    required this.patient,
    required this.doctor,
    this.booking,
    this.patientDetails,
    this.doctorDetails,
    required this.diagnosis,
    required this.medications,
    this.tests,
    this.notes,
    this.followUpDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['_id'] ?? json['id'] ?? '',
      patient: json['patient'] is String ? json['patient'] : json['patient']?['_id'] ?? '',
      doctor: json['doctor'] is String ? json['doctor'] : json['doctor']?['_id'] ?? '',
      booking: json['booking'],
      patientDetails: json['patient'] is Map ? User.fromJson(json['patient']) : null,
      doctorDetails: json['doctor'] is Map ? User.fromJson(json['doctor']) : null,
      diagnosis: json['diagnosis'] ?? '',
      medications: json['medications'] != null
          ? (json['medications'] as List).map((e) => Medication.fromJson(e)).toList()
          : [],
      tests: json['tests'] != null ? List<String>.from(json['tests']) : null,
      notes: json['notes'],
      followUpDate: json['followUpDate'] != null ? DateTime.parse(json['followUpDate']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient': patient,
      'doctor': doctor,
      if (booking != null) 'booking': booking,
      'diagnosis': diagnosis,
      'medications': medications.map((e) => e.toJson()).toList(),
      if (tests != null) 'tests': tests,
      if (notes != null) 'notes': notes,
      if (followUpDate != null) 'followUpDate': followUpDate!.toIso8601String(),
    };
  }
}

class Medication {
  final String name;
  final String dosage;
  final String frequency;
  final String duration;
  final String? instructions;

  Medication({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
    this.instructions,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      duration: json['duration'] ?? '',
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
      if (instructions != null) 'instructions': instructions,
    };
  }
}
