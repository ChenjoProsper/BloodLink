package com.bloodlinkproject.bloodlink.dto;

import java.util.UUID;

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

    private String prenom;

    @NotNull
    @Enumerated
    private Role role;

    @NotNull
    private UUID hopitalId;
}
