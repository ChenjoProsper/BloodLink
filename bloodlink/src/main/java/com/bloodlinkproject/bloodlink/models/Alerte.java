package com.bloodlinkproject.bloodlink.models;

import java.util.UUID;

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
}
