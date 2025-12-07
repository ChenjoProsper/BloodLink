import 'package:firebase_messaging/firebase_messaging.dart';
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

    /// Initialise les notifications
    Future<void> initialize() async {
        // Demande de permission
        NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('Permission notifications accordée');
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

        // Écoute des messages en avant-plan
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Écoute des messages en arrière-plan
        FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    }

    /// Récupère le token FCM
    Future<String?> getToken() async {
        try {
        String? token = await _firebaseMessaging.getToken();
        _logger.i('FCM Token: $token');
        return token;
        } catch (e) {
        _logger.e('Erreur récupération token FCM: $e');
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
        'BloodLink Alertes',
        channelDescription: 'Notifications pour les alertes de don de sang',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        );

        const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        );

        const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
        );

        await _localNotifications.show(id, title, body, details, payload: payload);
    }

    /// Gère les messages en avant-plan
    void _handleForegroundMessage(RemoteMessage message) {
        _logger.i('Message reçu en avant-plan: ${message.notification?.title}');
        
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
        _logger.i('Message ouvert depuis l\'arrière-plan: ${message.notification?.title}');
        // Navigation vers l'écran approprié
    }

    /// Gère le tap sur une notification
    void _onNotificationTapped(NotificationResponse response) {
        _logger.i('Notification tappée: ${response.payload}');
        // Navigation vers l'écran approprié
    }
    }

    /// Handler pour les messages en arrière-plan (top-level function)
    @pragma('vm:entry-point')
    Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    Logger().i('Message en arrière-plan: ${message.messageId}');
}