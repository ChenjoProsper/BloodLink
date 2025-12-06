package com.bloodlinkproject.bloodlink.services;

import lombok.experimental.UtilityClass;
import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

@UtilityClass
public class Utils {
    
    // --- 1. CALCUL DE DISTANCE (Formule de Haversine) ---

    public static double calculdist(double lat1, double lon1, double lat2, double lon2){
        // R : Rayon de la Terre en kilomètres
        double R = 6371; 
        double lat1Rad = Math.toRadians(lat1);
        double lon1Rad = Math.toRadians(lon1);
        double lat2Rad = Math.toRadians(lat2);
        double lon2Rad = Math.toRadians(lon2);

        double dLat = lat2Rad - lat1Rad;
        double dLon = lon2Rad - lon1Rad;

        // Formule Haversine
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) + 
                    Math.cos(lat1Rad) * Math.cos(lat2Rad) *
                    Math.sin(dLon / 2) * Math.sin(dLon / 2);
        
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        double distance = R * c; // Résultat en kilomètres

        return distance;
    }

    // --- 2. GÉOCODAGE (Obtention des coordonnées à partir de l'adresse) ---

    private static final HttpClient HTTP_CLIENT = HttpClient.newHttpClient();
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    /**
     * Effectue un appel d'API pour géocoder une adresse et retourne ses coordonnées.
     * @param adresse L'adresse complète à géocoder (ex: "1600 Amphitheatre Parkway, Mountain View").
     * @param apiKey La clé d'API (par exemple, pour OpenCage, Google Geocoding, etc.).
     * @return Un tableau de double contenant [latitude, longitude] ou null en cas d'échec.
     */
    public static double[] getCoordonnes(String adresse, String apiKey){
        // Utilisation de l'API OpenCage Geocoding comme exemple
        final String BASE_URL = "https://api.opencagedata.com/geocode/v1/json";
        
        try {
            // Encodage de l'adresse pour qu'elle puisse être intégrée dans l'URL
            String encodedAddress = URLEncoder.encode(adresse, StandardCharsets.UTF_8);

            String url = BASE_URL + "?q=" + encodedAddress + "&key=" + apiKey;
            
            // Création de la requête HTTP
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Accept", "application/json")
                    .build();

            // Envoi de la requête et réception de la réponse
            HttpResponse<String> response = HTTP_CLIENT.send(request, HttpResponse.BodyHandlers.ofString());
            
            // Vérification du statut de la réponse HTTP
            if (response.statusCode() != 200) {
                System.err.println("Erreur HTTP lors du géocodage: " + response.statusCode());
                return null;
            }

            // Analyse du corps JSON de la réponse
            JsonNode root = OBJECT_MAPPER.readTree(response.body());
            
            // L'API OpenCage stocke les résultats dans "results"
            if (root.has("results") && root.path("results").isArray() && root.path("results").size() > 0) {
                
                JsonNode geometry = root.path("results").get(0).path("geometry");
                
                if (geometry.has("lat") && geometry.has("lng")) {
                    double latitude = geometry.path("lat").asDouble();
                    double longitude = geometry.path("lng").asDouble();
                    
                    return new double[]{latitude, longitude};
                }
            }
            
            // Si aucune coordonnée n'a pu être extraite
            System.err.println("Géocodage réussi, mais aucune coordonnée trouvée pour l'adresse: " + adresse);
            return null;

        } catch (IOException | InterruptedException e) {
            System.err.println("Erreur lors de l'appel de l'API de géocodage: " + e.getMessage());
            return null;
        }
    }
}