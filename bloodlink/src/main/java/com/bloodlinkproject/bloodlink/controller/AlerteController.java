package com.bloodlinkproject.bloodlink.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import com.bloodlinkproject.bloodlink.dto.AlerteRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.models.Alerte;
import com.bloodlinkproject.bloodlink.services.AlerteService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/alertes")
@RequiredArgsConstructor
@Tag(name = "Alertes", description = "Gestion des alertes de don de sang")
@SecurityRequirement(name = "bearerAuth")
public class AlerteController {

    private final AlerteService alerteService;

    /**
     * Créer une nouvelle alerte de don de sang
     * POST /api/v1/alertes
     */
    @PostMapping
    @PreAuthorize("hasAuthority('MEDECIN')")
    @Operation(summary = "Créer une alerte", description = "Permet à un médecin de créer une alerte de don de sang")
    public ResponseEntity<Alerte> createAlerte(@Valid @RequestBody AlerteRequest alerteRequest) {
        Alerte alerte = alerteService.createAlerte(alerteRequest);
        return ResponseEntity.status(HttpStatus.CREATED).body(alerte);
    }

    /**
     * Recommander des donneurs proches
     * GET /api/v1/alertes/recommandations?latitude=3.8480&longitude=11.5021
     */
    @GetMapping("/recommandations")
    @PreAuthorize("hasAuthority('MEDECIN')")
    @Operation(summary = "Obtenir des donneurs recommandés", 
                description = "Trouve les donneurs dans un rayon de 5km autour d'une position")
    public ResponseEntity<List<UserResult>> recommandeDonneurs(
            @RequestParam double latitude,
            @RequestParam double longitude) {
        List<UserResult> donneurs = alerteService.recommandeDonne(latitude, longitude);
        return ResponseEntity.ok(donneurs);
    }
}