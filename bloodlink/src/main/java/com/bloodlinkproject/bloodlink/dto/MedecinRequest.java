package com.bloodlinkproject.bloodlink.dto;

import javax.management.relation.Role;

import jakarta.persistence.Enumerated;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class MedecinRequest {

    @NotNull
    @Email
    private String email;

    @NotNull
    private String password;

    private String nom;

    private String sexe;

    @NotNull
    @Enumerated
    private Role role;

    @NotNull
    private String adresse;

    private String numero;
}
