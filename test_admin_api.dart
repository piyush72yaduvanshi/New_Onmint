
void main() {
  // Simulate the exact API response
  final apiResponse = {
    "success": true,
    "message": "Users fetched",
    "data": {
      "users": [
        {
          "_id": "69bad990da608aef66ea389e",
          "email": "maurya@gmail.com",
          "role": "doctor",
          "firstName": "aBHISEK",
          "lastName": "mAURUEW",
          "phone": "8858729800",
          "status": "pending",
          "specialization": "asuhhfdds"
        },
        {
          "_id": "69bac517e76a8b7230ec2caa",
          "email": "doctornew@gmail.com",
          "role": "doctor",
          "firstName": "Doctor ka aadmin",
          "lastName": "baap",
          "phone": "9988776655",
          "status": "pending",
          "specialization": "iewufihes"
        }
      ],
      "total": 2,
      "page": 1,
      "limit": 20
    }
  };

  print('=== TESTING API RESPONSE PARSING ===');
  print('Full API Response: $apiResponse');
  print('');

  // Simulate what ApiClient passes to fromJson (the 'data' part)
  final dataFromApiClient = apiResponse['data'];
  print('Data passed to fromJson: $dataFromApiClient');
  print('Data type: ${dataFromApiClient.runtimeType}');
  print('');

  // Test the parsing logic
  final json = dataFromApiClient as Map<String, dynamic>;
  print('Testing parsing logic:');
  print('- Has users key: ${json.containsKey('users')}');
  print('- Users is List: ${json['users'] is List}');
  print('- Users length: ${json['users'] is List ? (json['users'] as List).length : 'N/A'}');
  print('');

  if (json['users'] is List) {
    final users = (json['users'] as List).cast<Map<String, dynamic>>();
    print('✅ SUCCESS: Extracted ${users.length} users');
    print('First user: ${users.first}');
  } else {
    print('❌ FAILED: Could not extract users');
  }
}