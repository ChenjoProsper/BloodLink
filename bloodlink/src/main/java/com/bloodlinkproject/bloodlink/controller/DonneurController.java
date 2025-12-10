package com.bloodlinkproject.bloodlink.controller;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import com.bloodlinkproject.bloodlink.dto.DonneurRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.models.Donneur;
import com.bloodlinkproject.bloodlink.services.DonneurService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/donneurs")
@RequiredArgsConstructor
@Tag(name = "Donneurs", description = "Gestion des donneurs de sang")
@SecurityRequirement(name = "bearerAuth")
public class DonneurController {

    private final DonneurService donneurService;

    /**
     * Créer un nouveau donneur
     * POST /api/v1/donneurs
     * Note: Cette route est redondante avec /api/v1/auth/register/donneur
     * Vous pouvez la supprimer ou la garder pour une gestion admin
     */
    @PostMapping
    @PreAuthorize("hasAuthority('ADMIN')")
    @Operation(summary = "Créer un donneur (Admin)", 
                description = "Permet à un admin de créer un donneur")
    public ResponseEntity<UserResult> createDonneur(@Valid @RequestBody DonneurRequest donneurRequest) {
        UserResult donneur = donneurService.createDonne(donneurRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(donneur);
    }

    /**
     * Lister tous les donneurs
     * GET /api/v1/donneurs
     */
    @GetMapping
    @PreAuthorize("hasAnyAuthority('MEDECIN', 'ADMIN')")
    @Operation(summary = "Lister tous les donneurs", 
               description = "Récupère la liste complète des donneurs")
    public ResponseEntity<List<Donneur>> getAllDonneurs() {
        List<Donneur> donneurs = donneurService.afficheAllDonne();
        return ResponseEntity.ok(donneurs);
    }

    /**
     * Mettre à jour la position d'un donneur
     * PATCH /api/v1/donneurs/{donneurId}/position?latitude=3.8480&longitude=11.5021
     */
    @PatchMapping("/{donneurId}/position")
    @PreAuthorize("hasAuthority('DONNEUR')")
    @Operation(summary = "Mettre à jour la position", 
                description = "Permet à un donneur de mettre à jour sa position GPS")
    public ResponseEntity<String> updatePosition(
            @PathVariable UUID donneurId,
            @RequestParam double latitude,
            @RequestParam double longitude) {
        String message = donneurService.updatePosition(donneurId, latitude, longitude);
        return ResponseEntity.ok(message);
    }

    /**
     * Obtenir un donneur par ID
     * GET /api/v1/donneurs/{donneurId}
     */
    @GetMapping("/{donneurId}")
    @PreAuthorize("hasAnyAuthority('DONNEUR', 'MEDECIN', 'ADMIN')")
    @Operation(summary = "Obtenir un donneur par ID", 
                description = "Récupère les informations d'un donneur spécifique")
    public ResponseEntity<Donneur> getDonneurById(@PathVariable UUID donneurId) {
        return ResponseEntity.ok(donneurService.findById(donneurId));
    }
        /**
     * Mettre à jour le FCM token du donneur
     * PATCH /api/v1/donneurs/{donneurId}/fcm-token
     */
    @PatchMapping("/{donneurId}/fcm-token")
    @PreAuthorize("hasAuthority('DONNEUR')")
    @Operation(summary = "Mettre à jour le FCM token")
    public ResponseEntity<String> updateFcmToken(
            @PathVariable UUID donneurId,
            @RequestBody Map<String, String> body) {
        
        String fcmToken = body.get("fcmToken");
        if (fcmToken == null || fcmToken.isEmpty()) {
            return ResponseEntity.badRequest().body("FCM token manquant");
        }
        
        // TODO: Implémenter la sauvegarde du token dans la base
        // donneurService.updateFcmToken(donneurId, fcmToken);
        
        return ResponseEntity.ok("FCM token mis à jour");
    }
}