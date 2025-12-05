package com.bloodlinkproject.bloodlink.models;

import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.validation.constraints.Email;
import lombok.Data;

@Entity
@Data
public class User {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID userId;
    
    @Email
    @Column(name = "email",unique = true,nullable = false)
    private String email;

    @Column(name = "password",nullable = false)
    private String password;

    @Column(name = "nom")
    private String nom;

    @Column(name = "sexe")
    private String sexe;

    @Column(name = "tel")
    private String numero;

    @Enumerated(EnumType.STRING)
    private Role role;
}
