library api_client;

// Base client
export 'src/api_client_base.dart';

// Configuration
export 'src/config/api_config.dart';

// Utils
export 'src/utils/response_handler.dart';

// Models
export 'src/models/models.dart';

// Services
export 'src/services/auth_api_service.dart';
export 'src/services/admin_api_service.dart';
export 'src/services/patient_api_service.dart';
export 'src/services/patient_service.dart';
export 'src/services/doctor_api_service.dart';
export 'src/services/nurse_api_service.dart';
export 'src/services/pharmacist_api_service.dart';
export 'src/services/ambulance_api_service.dart';
export 'src/services/payment_api_service.dart';
export 'src/services/socket_service.dart';
export 'src/services/document_api_service.dart';
export 'src/services/rating_api_service.dart';

// Main API Client Facade
import 'src/api_client_base.dart';
import 'src/services/auth_api_service.dart';
import 'src/services/admin_api_service.dart';
import 'src/services/patient_api_service.dart';
import 'src/services/doctor_api_service.dart';
import 'src/services/nurse_api_service.dart';
import 'src/services/pharmacist_api_service.dart';
import 'src/services/ambulance_api_service.dart';
import 'src/services/payment_api_service.dart';
import 'src/services/document_api_service.dart';
import 'src/services/rating_api_service.dart';

class OnMintApiClient {
  late final ApiClient _client;
  late final AuthApiService auth;
  late final AdminApiService admin;
  late final PatientApiService patient;
  late final DoctorApiService doctor;
  late final NurseApiService nurse;
  late final PharmacistApiService pharmacist;
  late final AmbulanceApiService ambulance;
  late final PaymentApiService payment;
  late final DocumentApiService document;
  late final RatingApiService rating;

  OnMintApiClient() {
    _client = ApiClient();
    auth = AuthApiService(_client);
    admin = AdminApiService(_client);
    patient = PatientApiService(_client);
    doctor = DoctorApiService(_client);
    nurse = NurseApiService(_client);
    pharmacist = PharmacistApiService(_client);
    ambulance = AmbulanceApiService(_client);
    payment = PaymentApiService(_client);
    document = DocumentApiService(_client);
    rating = RatingApiService(_client);
  }

  Future<void> initialize() async {
    await _client.loadToken();
  }

  Future<void> setAuthToken(String token) async {
    await _client.setAuthToken(token);
  }

  Future<void> clearAuthToken() async {
    await _client.clearAuthToken();
  }

  Future<void> clearToken() async {
    await _client.clearAuthToken();
  }

  bool get isAuthenticated => _client.isAuthenticated;
  String? get token => _client.token;
}
