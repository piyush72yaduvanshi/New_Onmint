import 'dart:io';

void main() {
  final filesToFix = [
    'user_app/lib/screens/services/ambulance_screen.dart',
    'user_app/lib/screens/services/bloodbank_screen.dart', 
    'user_app/lib/screens/services/booking_screen.dart',
    'user_app/lib/screens/services/booking_details_screen.dart',
    'user_app/lib/screens/services/my_bookings_screen.dart',
    'user_app/lib/screens/services/pathology_screen.dart',
    'user_app/lib/screens/services/services_screen.dart',
  ];

  for (final filePath in filesToFix) {
    final file = File(filePath);
    if (file.existsSync()) {
      String content = file.readAsStringSync();
      
      // Add PatientService import if not present
      if (!content.contains("import 'package:api_client/api_client.dart';")) {
        // Find the first import and add after it
        final lines = content.split('\n');
        int insertIndex = 0;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('import ')) {
            insertIndex = i + 1;
          } else if (lines[i].trim().isEmpty && insertIndex > 0) {
            break;
          }
        }
        
        lines.insert(insertIndex, "import 'package:api_client/api_client.dart';");
        content = lines.join('\n');
      }
      
      // Replace PatientService() with PatientService()
      content = content.replaceAll('PatientService _patientService;', 'PatientService _patientService = PatientService();');
      content = content.replaceAll('_patientService = PatientService();', '_patientService = PatientService();');
      
      file.writeAsStringSync(content);
      print('Fixed: $filePath');
    }
  }
}