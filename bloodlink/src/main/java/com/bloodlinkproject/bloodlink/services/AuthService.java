package com.bloodlinkproject.bloodlink.services;

import com.bloodlinkproject.bloodlink.config.JwtService;
import com.bloodlinkproject.bloodlink.dto.AuthResponse;
import com.bloodlinkproject.bloodlink.dto.DonneurRequest;
import com.bloodlinkproject.bloodlink.dto.MedecinRequest;
import com.bloodlinkproject.bloodlink.dto.UserAuth;
import com.bloodlinkproject.bloodlink.mapper.DonneurMapper;
import com.bloodlinkproject.bloodlink.mapper.MedecinMapper;
import com.bloodlinkproject.bloodlink.models.Donneur;
import com.bloodlinkproject.bloodlink.models.Medecin;
import com.bloodlinkproject.bloodlink.models.User;
import com.bloodlinkproject.bloodlink.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final JwtService jwtService;
    private final DonneurMapper donneurMapper;
    private final MedecinMapper medecinMapper;
    private final AuthenticationManager authenticationManager;

    /**
     * Inscription d'un donneur
     */
    @Transactional
    public AuthResponse registerDonneur(DonneurRequest request) {
        // Vérifier si l'email existe déjà
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email déjà utilisé");
        }

        // Créer le donneur
        Donneur donneur = donneurMapper.toEntity(request);

        // Sauvegarder
        User savedUser = userRepository.save(donneur);

        // Générer le token JWT
        String token = jwtService.generateToken(savedUser);

        return AuthResponse.builder()
                .token(token)
                .email(savedUser.getEmail())
                .role(savedUser.getRole().name())
                .message("Donneur inscrit avec succès")
                .build();
    }

    /**
     * Inscription d'un médecin
     */
    @Transactional
    public AuthResponse registerMedecin(MedecinRequest request) {
        // Vérifier si l'email existe déjà
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email déjà utilisé");
        }

        // Créer le médecin
        Medecin medecin = medecinMapper.toEntity(request);

        // Sauvegarder
        User savedUser = userRepository.save(medecin);

        // Générer le token JWT
        String token = jwtService.generateToken(savedUser);

        return AuthResponse.builder()
                .token(token)
                .email(savedUser.getEmail())
                .role(savedUser.getRole().name())
                .message("Médecin inscrit avec succès")
                .build();
    }

    /**
     * Connexion (Login)
     */
    public AuthResponse login(UserAuth request) {
        // Authentifier l'utilisateur
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );

        // Récupérer l'utilisateur
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        // Générer le token JWT
        String token = jwtService.generateToken(user);

        return AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .role(user.getRole().name())
                .message("Connexion réussie")
                .build();
    }
}
