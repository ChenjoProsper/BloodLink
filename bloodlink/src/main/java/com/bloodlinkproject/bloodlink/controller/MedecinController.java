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

    /**
     * Créer un nouveau médecin
     * POST /api/v1/medecins
     * Note: Cette route est redondante avec /api/v1/auth/register/medecin
     */
    @PostMapping
    @PreAuthorize("hasAuthority('ADMIN')")
    @Operation(summary = "Créer un médecin (Admin)", 
               description = "Permet à un admin de créer un médecin")
    public ResponseEntity<UserResult> createMedecin(@Valid @RequestBody MedecinRequest medecinRequest) {
        UserResult medecin = medecinService.createMedecin(medecinRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(medecin);
    }

    /**
     * Lister tous les médecins
     * GET /api/v1/medecins
     */
    @GetMapping
    @PreAuthorize("hasAnyAuthority('MEDECIN', 'ADMIN')")
    @Operation(summary = "Lister tous les médecins", 
               description = "Récupère la liste complète des médecins")
    public ResponseEntity<List<Medecin>> getAllMedecins() {
        List<Medecin> medecins = medecinService.afficheAllDonne();
        return ResponseEntity.ok(medecins);
    }

    /**
     * Obtenir les coordonnées GPS d'un médecin
     * GET /api/v1/medecins/{medecinId}/coordonnees
     */
    @GetMapping("/{medecinId}/coordonnees")
    @PreAuthorize("hasAnyAuthority('MEDECIN', 'DONNEUR', 'ADMIN')")
    @Operation(summary = "Obtenir les coordonnées d'un médecin", 
               description = "Convertit l'adresse du médecin en coordonnées GPS")
    public ResponseEntity<Map<String, Double>> getCoordonnesByMedecin(@PathVariable UUID medecinId) {
        double[] coordonnees = medecinService.getCoordonnesByMedecin(medecinId);
        return ResponseEntity.ok(Map.of(
            "latitude", coordonnees[0],
            "longitude", coordonnees[1]
        ));
    }

    /**
     * Obtenir les coordonnées GPS d'une adresse
     * GET /api/v1/medecins/coordonnees?adresse=Hopital Central Yaounde
     */
    @GetMapping("/coordonnees")
    @PreAuthorize("hasAnyAuthority('MEDECIN', 'DONNEUR', 'ADMIN')")
    @Operation(summary = "Obtenir les coordonnées d'une adresse", 
                description = "Convertit une adresse en coordonnées GPS via API de géolocalisation")
    public ResponseEntity<Map<String, Double>> getCoordonnesByAdresse(@RequestParam String adresse) {
        double[] coordonnees = medecinService.getCoordonnesByAdresse(adresse);
        return ResponseEntity.ok(Map.of(
            "latitude", coordonnees[0],
            "longitude", coordonnees[1]
        ));
    }
}