package com.bloodlinkproject.bloodlink.controller;

import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import com.bloodlinkproject.bloodlink.dto.ReponseRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.services.ReponseService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/v1/reponses")
@RequiredArgsConstructor
@Tag(name = "Réponses", description = "Gestion des réponses aux alertes")
@SecurityRequirement(name = "bearerAuth")
public class ReponseController {

    private final ReponseService reponseService;

    /**
     * Accepter une demande de don
     * POST /api/v1/reponses/accepter
     */
    @PostMapping("/accepter")
    @PreAuthorize("hasAuthority('DONNEUR')")
    @Operation(summary = "Accepter une demande de don", 
               description = "Permet à un donneur d'accepter une alerte de don de sang")
    public ResponseEntity<UserResult> accepterDemande(@Valid @RequestBody ReponseRequest reponseRequest) {
        try {
            UserResult donneur = reponseService.accepterDemande(reponseRequest);
            return ResponseEntity.status(HttpStatus.CREATED).body(donneur);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(null); // Ou créer un DTO d'erreur personnalisé
        }
    }

    /**
     * Valider une alerte (terminer le don)
     * PATCH /api/v1/reponses/{reponseId}/valider
     */
    @PatchMapping("/{reponseId}/valider")
    @PreAuthorize("hasAuthority('MEDECIN')")
    @Operation(summary = "Valider une alerte", 
                description = "Permet à un médecin de valider qu'un don a été effectué et créditer le donneur")
    public ResponseEntity<String> validerAlerte(@PathVariable UUID reponseId) {
        String message = reponseService.validerAlerte(reponseId);
        return ResponseEntity.ok(message);
    }
}