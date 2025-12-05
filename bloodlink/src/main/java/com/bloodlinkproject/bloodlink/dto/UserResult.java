package com.bloodlinkproject.bloodlink.dto;

import java.util.UUID;

import lombok.Data;

@Data
public class UserResult {

    private UUID userId;

    private String email;

    private String password;

    private String nom;

    private String prenom;

    private String role;
}
