package com.bloodlinkproject.bloodlink.dto;

import com.bloodlinkproject.bloodlink.models.GroupeSanguin;

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
    private GroupeSanguin gsang;

    private double latitude;

    private double longitude; 
    
    private String numero;
}
