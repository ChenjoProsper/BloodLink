import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final _logger = Logger();

  String? _fcmToken;

  /// Initialise les notifications
  Future<void> initialize() async {
    // Demande de permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
      announcement: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      _logger.i('✅ Permission notifications accordée');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      _logger.i('⚠️ Permission notifications provisoire');
    } else {
      _logger.w('❌ Permission notifications refusée');
    }

    // Configuration notifications locales Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration notifications locales iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Créer le canal de notification Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'bloodlink_channel',
      'Alertes BloodLink',
      description: 'Notifications pour les alertes de don de sang urgentes',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Écoute des messages en avant-plan
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Écoute des messages en arrière-plan (ouvre l'app)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // Vérifie si l'app a été ouverte depuis une notification
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }

    _logger.i('✅ Notifications initialisées');
  }

  /// Récupère le token FCM
  Future<String?> getToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      _logger.i('📱 FCM Token: $_fcmToken');

      // Écouter les changements de token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        _logger.i('🔄 FCM Token rafraîchi: $newToken');
        // TODO: Envoyer le nouveau token au backend
      });

      return _fcmToken;
    } catch (e) {
      _logger.e('❌ Erreur récupération token FCM: $e');
      return null;
    }
  }

  /// Affiche une notification locale
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'bloodlink_channel',
      'Alertes BloodLink',
      channelDescription: 'Notifications pour les alertes de don de sang',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFFE74C3C),
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
    _logger.i('🔔 Notification affichée: $title');
  }

  /// Gère les messages en avant-plan
  void _handleForegroundMessage(RemoteMessage message) {
    _logger.i('📨 Message reçu en avant-plan: ${message.notification?.title}');

    if (message.notification != null) {
      showLocalNotification(
        id: message.hashCode,
        title: message.notification!.title ?? 'BloodLink',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Gère les messages en arrière-plan
  void _handleBackgroundMessage(RemoteMessage message) {
    _logger.i(
        '📬 Message ouvert depuis l\'arrière-plan: ${message.notification?.title}');

    // Navigation vers l'écran approprié selon le type
    final type = message.data['type'];
    final alerteId = message.data['alerteId'];

    if (type == 'ALERTE' && alerteId != null) {
      // TODO: Naviguer vers l'écran de détails de l'alerte
      _logger.i('🩸 Navigation vers alerte: $alerteId');
    }
  }

  /// Gère le tap sur une notification
  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('👆 Notification tappée: ${response.payload}');

    // TODO: Naviguer vers l'écran approprié
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    _logger.i('🚫 Toutes les notifications annulées');
  }
}

/// Handler pour les messages en arrière-plan (top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger().i('🌙 Message en arrière-plan: ${message.messageId}');
}
