package com.bloodlinkproject.bloodlink.controller;

import com.bloodlinkproject.bloodlink.dto.AuthResponse;
import com.bloodlinkproject.bloodlink.dto.DonneurRequest;
import com.bloodlinkproject.bloodlink.dto.MedecinRequest;
import com.bloodlinkproject.bloodlink.dto.UserAuth;
import com.bloodlinkproject.bloodlink.services.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /**
     * POST /api/v1/auth/login
     * Connexion d'un utilisateur
     */
    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody UserAuth request) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(AuthResponse.builder()
                            .message("Email ou mot de passe incorrect")
                            .build());
        }
    }

    /**
     * POST /api/v1/auth/register/donneur
     * Inscription d'un donneur
     */
    @PostMapping("/register/donneur")
    public ResponseEntity<AuthResponse> registerDonneur(@Valid @RequestBody DonneurRequest request) {
        try {
            AuthResponse response = authService.registerDonneur(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(AuthResponse.builder()
                            .message(e.getMessage())
                            .build());
        }
    }

    /**
     * POST /api/v1/auth/register/medecin
     * Inscription d'un médecin
     */
    @PostMapping("/register/medecin")
    public ResponseEntity<AuthResponse> registerMedecin(@Valid @RequestBody MedecinRequest request) {
        try {
            AuthResponse response = authService.registerMedecin(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT)
                    .body(AuthResponse.builder()
                            .message(e.getMessage())
                            .build());
        }
    }
}