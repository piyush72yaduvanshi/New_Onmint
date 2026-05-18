import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:api_client/api_client.dart';

class VideoConsultationScreen extends StatefulWidget {
  final String bookingId;

  const VideoConsultationScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<VideoConsultationScreen> createState() =>
      _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _meetingConfig;

  @override
  void initState() {
    super.initState();
    _loadMeetingDetails();
  }

  Future<void> _loadMeetingDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final apiClient = ApiClient();
      final response = await apiClient.post(
        '/video/room',
        data: {'bookingId': widget.bookingId},
      );

      if (response.data['success'] == true) {
        setState(() {
          _meetingConfig = response.data['data'];
          _isLoading = false;
        });

        // Initialize WebView with Zoom meeting
        _initializeWebView();
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? 'Failed to load meeting';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _initializeWebView() {
    if (_meetingConfig == null) return;

    // Create HTML content with Zoom SDK
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Video Consultation</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: Arial, sans-serif;
            background: #000;
            color: white;
        }
        #container {
            width: 100%;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }
        #header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 15px;
            text-align: center;
        }
        #video-container {
            flex: 1;
            background: #000;
        }
        #controls {
            padding: 15px;
            background: #1a1a1a;
            display: flex;
            justify-content: center;
            gap: 10px;
        }
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            color: white;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .btn-danger {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        .loading {
            text-align: center;
            padding: 50px;
        }
        .spinner {
            border: 4px solid rgba(255, 255, 255, 0.3);
            border-top: 4px solid white;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>
</head>
<body>
    <div id="container">
        <div id="header">
            <h2>🏥 Video Consultation</h2>
            <p>Booking ID: ${widget.bookingId}</p>
        </div>
        <div id="video-container">
            <div class="loading">
                <div class="spinner"></div>
                <p>Initializing video consultation...</p>
            </div>
        </div>
        <div id="controls">
            <button class="btn btn-primary" id="join-btn" onclick="joinMeeting()">
                📹 Join Consultation
            </button>
            <button class="btn btn-danger" id="leave-btn" onclick="leaveMeeting()" style="display: none;">
                📞 Leave Consultation
            </button>
        </div>
    </div>

    <!-- Zoom Web SDK -->
    <script src="https://source.zoom.us/3.8.10/lib/vendor/react.min.js"></script>
    <script src="https://source.zoom.us/3.8.10/lib/vendor/react-dom.min.js"></script>
    <script src="https://source.zoom.us/3.8.10/lib/vendor/redux.min.js"></script>
    <script src="https://source.zoom.us/3.8.10/lib/vendor/redux-thunk.min.js"></script>
    <script src="https://source.zoom.us/3.8.10/lib/vendor/lodash.min.js"></script>
    <script src="https://source.zoom.us/zoom-meeting-3.8.10.min.js"></script>

    <script>
        const meetingConfig = ${_getMeetingConfigJson()};
        let ZoomMtg = window.ZoomMtg;

        // Initialize Zoom SDK
        ZoomMtg.preLoadWasm();
        ZoomMtg.prepareWebSDK();

        function joinMeeting() {
            document.getElementById('join-btn').disabled = true;
            document.getElementById('join-btn').textContent = 'Joining...';

            ZoomMtg.init({
                leaveUrl: 'about:blank',
                success: function() {
                    ZoomMtg.join({
                        meetingNumber: meetingConfig.meetingId,
                        userName: meetingConfig.role === 'host' ? 'Doctor' : 'Patient',
                        signature: meetingConfig.token,
                        sdkKey: meetingConfig.sdkKey,
                        passWord: meetingConfig.meetingPassword,
                        success: function(res) {
                            console.log('Join meeting success', res);
                            document.getElementById('join-btn').style.display = 'none';
                            document.getElementById('leave-btn').style.display = 'block';
                            document.querySelector('.loading').style.display = 'none';
                        },
                        error: function(error) {
                            console.error('Join meeting error:', error);
                            alert('Failed to join meeting: ' + error.reason);
                            document.getElementById('join-btn').disabled = false;
                            document.getElementById('join-btn').textContent = '📹 Join Consultation';
                        }
                    });
                },
                error: function(error) {
                    console.error('Init error:', error);
                    alert('Failed to initialize Zoom: ' + error.reason);
                    document.getElementById('join-btn').disabled = false;
                    document.getElementById('join-btn').textContent = '📹 Join Consultation';
                }
            });
        }

        function leaveMeeting() {
            ZoomMtg.leaveMeeting({
                success: function() {
                    window.location.reload();
                },
                error: function(error) {
                    console.error('Leave meeting error:', error);
                }
            });
        }
    </script>
</body>
</html>
    ''';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadHtmlString(htmlContent);
  }

  String _getMeetingConfigJson() {
    if (_meetingConfig == null) return '{}';
    return '''
{
  "meetingId": "${_meetingConfig!['meetingId']}",
  "meetingPassword": "${_meetingConfig!['meetingPassword']}",
  "token": "${_meetingConfig!['token']}",
  "sdkKey": "${_meetingConfig!['sdkKey']}",
  "role": "${_meetingConfig!['role']}"
}
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Video Consultation'),
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading consultation...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loadMeetingDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_meetingConfig != null) {
      return Column(
        children: [
          // Meeting info card
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF1a1a1a),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 Consultation Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Doctor',
                  _meetingConfig!['participants']['doctor']['name'],
                ),
                _buildInfoRow(
                  'Patient',
                  _meetingConfig!['participants']['patient']['name'],
                ),
                _buildInfoRow(
                  'Role',
                  _meetingConfig!['role'] == 'host' ? 'Doctor' : 'Patient',
                ),
              ],
            ),
          ),
          // WebView
          Expanded(
            child: WebViewWidget(controller: _webViewController),
          ),
        ],
      );
    }

    return const Center(
      child: Text(
        'No meeting data available',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
