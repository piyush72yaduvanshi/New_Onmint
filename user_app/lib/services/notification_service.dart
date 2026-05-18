// Firebase packages are not installed yet - commenting out for now
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification service for handling push notifications
/// TODO: Install firebase_messaging and flutter_local_notifications packages
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // TODO: Uncomment when Firebase packages are installed
    /*
    try {
      // Request permission
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permission granted');

        // Get FCM token
        _fcmToken = await _firebaseMessaging.getToken();
        print('📱 FCM Token: $_fcmToken');

        // Initialize local notifications
        await _initializeLocalNotifications();

        // Setup message handlers
        _setupMessageHandlers();

        _isInitialized = true;
      } else {
        print('❌ Notification permission denied');
      }
    } catch (e) {
      print('⚠️ Error initializing notifications: $e');
    }
    */
    _isInitialized = true;
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // TODO: Uncomment when packages are installed
    /*
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    */
  }

  /// Setup message handlers
  void _setupMessageHandlers() {
    // TODO: Uncomment when packages are installed
    /*
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background messages
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Terminated state messages
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleBackgroundMessage(message);
      }
    });

    // Token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      // TODO: Send new token to backend
    });
    */
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(dynamic message) async {
    // TODO: Uncomment when packages are installed
    /*
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      await _showLocalNotification(
        title: notification.title ?? 'OnMint Healthcare',
        body: notification.body ?? '',
        payload: data.toString(),
      );
    }
    */
  }

  /// Handle background/terminated messages
  void _handleBackgroundMessage(dynamic message) {
    // TODO: Uncomment when packages are installed
    /*
    final data = message.data;
    _handleNotificationNavigation(data);
    */
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    // TODO: Uncomment when packages are installed
    /*
    const androidDetails = AndroidNotificationDetails(
      'onmint_channel',
      'OnMint Notifications',
      channelDescription: 'OnMint Healthcare notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
    */
  }

  /// Handle notification tap
  void _onNotificationTapped(dynamic response) {
    // TODO: Uncomment when packages are installed
    /*
    if (response.payload != null) {
      _handleNotificationNavigation({});
    }
    */
  }

  /// Handle notification navigation
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // TODO: Implement navigation based on notification type when Firebase is installed
    // Examples:
    // - 'booking' -> Navigate to booking details
    // - 'message' -> Navigate to chat
    // - 'payment' -> Navigate to payment screen
    // - 'prescription' -> Navigate to prescription viewer
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    // TODO: Uncomment when packages are installed
    /*
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      // Handle error
    }
    */
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    // TODO: Uncomment when packages are installed
    /*
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      // Handle error
    }
    */
  }

  /// Get badge count (iOS)
  Future<int> getBadgeCount() async {
    // iOS only
    return 0;
  }

  /// Set badge count (iOS)
  Future<void> setBadgeCount(int count) async {
    // iOS only - requires Firebase
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    // TODO: Uncomment when packages are installed
    // await _localNotifications.cancelAll();
  }

  /// Send FCM token to backend
  Future<void> sendTokenToBackend(String token) async {
    // TODO: Implement API call to save FCM token
  }
}

/// Background message handler (must be top-level function)
/// TODO: Uncomment when Firebase packages are installed
/*
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(dynamic message) async {
  // await Firebase.initializeApp();
}
*/
