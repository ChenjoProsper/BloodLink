package com.bloodlinkproject.bloodlink.dto;

import java.util.UUID;

import lombok.Data;

@Data
public class ReponseResult {
    private UUID reponseId;
    private String email;
    private String nom;
    private String sexe;
    private String numero;
}
