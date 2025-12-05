package com.bloodlinkproject.bloodlink.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class DonneurRequest {

    @NotNull
    @Email
    private String email;

    @NotNull
    private String password;

    private String nom;

    private String sexe;

    @NotNull
    private String gsang;

    private Long latitude;

    private Long longitude; 
    
    private String nuumro;
}
