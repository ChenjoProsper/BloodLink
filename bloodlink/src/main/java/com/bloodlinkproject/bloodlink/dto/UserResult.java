package com.bloodlinkproject.bloodlink.dto;

import com.bloodlinkproject.bloodlink.models.GroupeSanguin;
import com.bloodlinkproject.bloodlink.models.Role;
import lombok.Data;

import java.util.UUID;

@Data
public class UserResult {
    private UUID userId;
    private String email;
    private String nom;
    private String sexe;
    private String numero;
    private Role role;
    
    // Champs spécifiques au donneur
    private GroupeSanguin gsang;
    private Double latitude;
    private Double longitude;
    private Double solde;
    
    // Champs spécifiques au médecin
    private String adresse;
}