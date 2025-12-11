package com.bloodlinkproject.bloodlink.models;

import java.util.UUID;
import java.util.Set; // Import nécessaire
import java.util.HashSet; // Import nécessaire

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany; // Import nécessaire
import jakarta.persistence.CascadeType; // Import nécessaire
import lombok.Data;

@Entity
@Data
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Alerte {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID alerteId;

    @Enumerated(EnumType.STRING)
    private GroupeSanguin gsang;

    @Column(name = "description")
    private String description;

    @Column(name = "etat")
    private String etat = "EN COUR";

    @Column(name = "remuneration")
    private double remuneration = 0.0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private Medecin medecin;

    // 💡 AJOUT : Relation One-to-Many vers Reponse
    @OneToMany(mappedBy = "alerte", cascade = CascadeType.ALL, orphanRemoval = true)
    private Set<Reponse> reponses = new HashSet<>();
}
