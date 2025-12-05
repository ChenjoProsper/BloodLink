package com.bloodlinkproject.bloodlink.models;

import java.util.UUID;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Data;

@Entity
@Data
public class Alerte {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID alerteId;

    @Column(name = "groupe_sanguin",nullable = false)
    private String gsang;

    @Column(name = "description")
    private String description;

    @Column(name = "etat")
    private String etat = "EN COUR";

    @Column(name = "remuneration")
    private Long remuneration = 0L;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private Medecin medecin;
}
