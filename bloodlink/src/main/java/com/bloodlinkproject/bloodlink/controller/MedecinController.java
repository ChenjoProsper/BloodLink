package com.bloodlinkproject.bloodlink.controller;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import com.bloodlinkproject.bloodlink.dto.MedecinRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.models.Medecin;
import com.bloodlinkproject.bloodlink.services.MedecinService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/medecins")
@RequiredArgsConstructor
@Tag(name = "Médecins", description = "Gestion des médecins")
@SecurityRequirement(name = "bearerAuth")
public class MedecinController {

    private final MedecinService medecinService;

    @PostMapping
    @PreAuthorize("hasAuthority('ADMIN')")
    @Operation(summary = "Créer un médecin (Admin)")
    public ResponseEntity<UserResult> createMedecin(@Valid @RequestBody MedecinRequest medecinRequest) {
        UserResult medecin = medecinService.createMedecin(medecinRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(medecin);
    }

    @GetMapping
    @PreAuthorize("hasAnyAuthority('MEDECIN', 'ADMIN')")
    @Operation(summary = "Lister tous les médecins")
    public ResponseEntity<List<Medecin>> getAllMedecins() {
        List<Medecin> medecins = medecinService.afficheAllDonne();
        return ResponseEntity.ok(medecins);
    }

    /**
     * Obtenir les coordonnées GPS d'un médecin
     */
    @GetMapping("/{medecinId}/coordonnees")
    @PreAuthorize("hasAnyAuthority('MEDECIN', 'DONNEUR', 'ADMIN')")
    @Operation(summary = "Obtenir les coordonnées d'un médecin")
    public ResponseEntity<?> getCoordonnesByMedecin(@PathVariable UUID medecinId) {
        try {
            double[] coordonnees = medecinService.getCoordonnesByMedecin(medecinId);
            
            // ✅ Vérification si coordonnees est null
            if (coordonnees == null) {
                return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                        .body(Map.of(
                            "error", "Impossible de géolocaliser l'adresse",
                            "message", "Vérifiez votre clé API OpenCage ou l'adresse du médecin"
                        ));
            }
            
            return ResponseEntity.ok(Map.of(
                "latitude", coordonnees[0],
                "longitude", coordonnees[1]
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of(
                        "error", "Erreur serveur",
                        "message", e.getMessage()
                    ));
        }
    }

    /**
     * Obtenir les coordonnées GPS d'une adresse
     */
    @GetMapping("/coordonnees")
    @PreAuthorize("hasAnyAuthority('MEDECIN', 'DONNEUR', 'ADMIN')")
    @Operation(summary = "Obtenir les coordonnées d'une adresse")
    public ResponseEntity<?> getCoordonnesByAdresse(@RequestParam String adresse) {
        try {
            double[] coordonnees = medecinService.getCoordonnesByAdresse(adresse);
            
            // ✅ Vérification si coordonnees est null
            if (coordonnees == null) {
                return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                        .body(Map.of(
                            "error", "Impossible de géolocaliser l'adresse",
                            "message", "Vérifiez votre clé API OpenCage ou l'adresse fournie",
                            "adresse", adresse
                        ));
            }
            
            return ResponseEntity.ok(Map.of(
                "adresse", adresse,
                "latitude", coordonnees[0],
                "longitude", coordonnees[1]
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of(
                        "error", "Erreur serveur",
                        "message", e.getMessage()
                    ));
        }
    }
}