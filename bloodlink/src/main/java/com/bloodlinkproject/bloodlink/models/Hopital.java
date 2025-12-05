package com.bloodlinkproject.bloodlink.models;

import java.util.List;
import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToMany;
import lombok.Data;

@Entity
@Data
public class Hopital {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID hopitalId;

    @Column(name = "nom",nullable = false)
    private String nom;

    @Column(name = "adresse",nullable = false)
    private String adresse;

    @OneToMany
    private List<Medecin> medecins;
}
