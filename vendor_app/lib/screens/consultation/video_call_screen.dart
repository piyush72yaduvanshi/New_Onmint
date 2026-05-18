import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:api_client/api_client.dart';

/// Video call screen using Zoom Web SDK via WebView
class VideoCallScreen extends StatefulWidget {
  final String meetingId;
  final String userName;
  final String? bookingId;

  const VideoCallScreen({
    super.key,
    required this.meetingId,
    required this.userName,
    this.bookingId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _apiClient = OnMintApiClient();
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _isInitializing = true;
  String? _errorMessage;
  Map<String, dynamic>? _videoRoomData;

  @override
  void initState() {
    super.initState();
    _initializeVideoCall();
  }

  Future<void> _initializeVideoCall() async {
    setState(() => _isInitializing = true);
    
    try {
      await _apiClient.initialize();
      
      // Create or join video room
      if (widget.bookingId != null) {
        final roomData = await _apiClient.doctor.createVideoRoom(widget.bookingId!);
        setState(() {
          _videoRoomData = roomData;
          _isInitializing = false;
        });
        
        // Initialize WebView with Zoom Web SDK
        _initializeWebView();
      } else {
        setState(() {
          _errorMessage = 'Booking ID is required for video call';
          _isInitializing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize video call: $e';
        _isInitializing = false;
      });
    }
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(_buildZoomWebSDKHtml());
  }

  String _buildZoomWebSDKHtml() {
    final meetingId = _videoRoomData?['meetingId'] ?? widget.meetingId;
    final password = _videoRoomData?['meetingPassword'] ?? '';
    final token = _videoRoomData?['token'] ?? '';
    final sdkKey = _videoRoomData?['sdkKey'] ?? '';
    final userName = widget.userName;

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Video Call</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
      background: #1a1a1a;
      color: white;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100vh;
      overflow: hidden;
    }
    #video-container {
      width: 100%;
      height: 100%;
      position: relative;
      background: #000;
    }
    #controls {
      position: absolute;
      bottom: 20px;
      left: 50%;
      transform: translateX(-50%);
      display: flex;
      gap: 15px;
      z-index: 1000;
    }
    .control-btn {
      width: 50px;
      height: 50px;
      border-radius: 50%;
      border: none;
      background: rgba(255, 255, 255, 0.2);
      color: white;
      font-size: 20px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: all 0.3s;
    }
    .control-btn:hover {
      background: rgba(255, 255, 255, 0.3);
    }
    .control-btn.end-call {
      background: #ff4444;
    }
    .control-btn.end-call:hover {
      background: #cc0000;
    }
    #status {
      position: absolute;
      top: 20px;
      left: 50%;
      transform: translateX(-50%);
      background: rgba(0, 0, 0, 0.7);
      padding: 10px 20px;
      border-radius: 20px;
      font-size: 14px;
      z-index: 1000;
    }
    .loading {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 20px;
    }
    .spinner {
      width: 50px;
      height: 50px;
      border: 4px solid rgba(255, 255, 255, 0.3);
      border-top-color: white;
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      to { transform: rotate(360deg); }
    }
  </style>
</head>
<body>
  <div id="video-container">
    <div id="status">Connecting to video call...</div>
    <div class="loading">
      <div class="spinner"></div>
      <p>Initializing video call...</p>
    </div>
    <div id="controls" style="display: none;">
      <button class="control-btn" id="mute-btn" onclick="toggleMute()">🎤</button>
      <button class="control-btn" id="video-btn" onclick="toggleVideo()">📹</button>
      <button class="control-btn end-call" onclick="endCall()">📞</button>
    </div>
  </div>

  <script>
    // Zoom Web SDK integration would go here
    // For now, this is a placeholder that shows the UI structure
    
    let isMuted = false;
    let isVideoOff = false;
    
    // Simulate connection after 2 seconds
    setTimeout(() => {
      document.querySelector('.loading').style.display = 'none';
      document.getElementById('controls').style.display = 'flex';
      document.getElementById('status').textContent = 'Connected';
      
      // Hide status after 3 seconds
      setTimeout(() => {
        document.getElementById('status').style.display = 'none';
      }, 3000);
    }, 2000);
    
    function toggleMute() {
      isMuted = !isMuted;
      const btn = document.getElementById('mute-btn');
      btn.textContent = isMuted ? '🔇' : '🎤';
      btn.style.background = isMuted ? '#ff4444' : 'rgba(255, 255, 255, 0.2)';
    }
    
    function toggleVideo() {
      isVideoOff = !isVideoOff;
      const btn = document.getElementById('video-btn');
      btn.textContent = isVideoOff ? '📷' : '📹';
      btn.style.background = isVideoOff ? '#ff4444' : 'rgba(255, 255, 255, 0.2)';
    }
    
    function endCall() {
      // Send message to Flutter to close the screen
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('endCall');
      }
      document.getElementById('status').textContent = 'Call ended';
      document.getElementById('status').style.display = 'block';
    }
    
    // Note: Full Zoom Web SDK integration requires:
    // 1. Loading Zoom Web SDK from CDN
    // 2. Initializing with SDK key and meeting credentials
    // 3. Handling video/audio streams
    // 4. Managing participant events
    // This is a simplified placeholder for demonstration
  </script>
</body>
</html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isInitializing
            ? _buildInitializingView()
            : _errorMessage != null
                ? _buildErrorView()
                : Stack(
                    children: [
                      WebViewWidget(controller: _webViewController),
                      if (_isLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          onPressed: () => _confirmEndCall(),
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildInitializingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 24),
          Text(
            'Initializing video call...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to start video call',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Unknown error',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmEndCall() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Call'),
        content: const Text('Are you sure you want to end this video call?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('End Call'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _endVideoCall();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _endVideoCall() async {
    if (widget.bookingId != null) {
      try {
        await _apiClient.doctor.endVideoCall(widget.bookingId!);
      } catch (e) {
        debugPrint('Error ending video call: $e');
      }
    }
  }

  @override
  void dispose() {
    _endVideoCall();
    super.dispose();
  }
}
