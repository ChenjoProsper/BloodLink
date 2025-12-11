// Fichier: ReponseResult.java (CORRIGÉ)
package com.bloodlinkproject.bloodlink.dto;

import java.time.LocalDateTime;
import java.util.UUID;

import lombok.Data;

@Data
public class ReponseResult {
    private UUID reponseId;

    private AlerteResult alerte; 

    private UserResult donneur; 

    private String statut;
    private LocalDateTime dateReponse;
}