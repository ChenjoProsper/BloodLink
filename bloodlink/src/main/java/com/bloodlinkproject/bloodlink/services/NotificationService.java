package com.bloodlinkproject.bloodlink.services;

import com.bloodlinkproject.bloodlink.models.Alerte;
import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.MulticastMessage;
import com.google.firebase.messaging.Notification;

import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Map;
@Service
public class NotificationService {

    public void sendNotificationToToken(String token, String title, String body, Map<String, String> data) {
        Message message = Message.builder()
            .setToken(token)
            .setNotification(Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build())
            .putAllData(data)
            .build();

        try {
            String response = FirebaseMessaging.getInstance().send(message);
            System.out.println("Notification envoyée: " + response);
        } catch (Exception e) {
            System.err.println("Erreur envoi notification: " + e.getMessage());
        }
    }

    public void sendAlerteToDonneurs(List<String> donneurTokens, Alerte alerte) {
        MulticastMessage message = MulticastMessage.builder()
            .addAllTokens(donneurTokens)
            .setNotification(Notification.builder()
                .setTitle("🩸 Nouvelle alerte de don")
                .setBody("Groupe " + alerte.getGsang() + " - " + alerte.getDescription())
                .build())
            .putData("alerteId", alerte.getAlerteId().toString())
            .putData("type", "ALERTE")
            .build();

        try {
            BatchResponse response = FirebaseMessaging.getInstance().sendEachForMulticast(message);
            System.out.println("Notifications envoyées: " + response.getSuccessCount());
        } catch (Exception e) {
            System.err.println("Erreur envoi notifications: " + e.getMessage());
        }
    }
}