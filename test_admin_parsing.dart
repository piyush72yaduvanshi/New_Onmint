// Test to verify admin response parsing

void main() {
  // This is the exact response format from your backend
  final backendResponse = {
    "success": true,
    "message": "Login successful",
    "data": {
      "user": {
        "location": {
          "type": "Point",
          "coordinates": [78.60018192492034, 25.45370447621787]
        },
        "_id": "69b8c42a932e41d1a4532e67",
        "email": "admin@gmail.com",
        "role": "admin",  // ← This should be parsed correctly