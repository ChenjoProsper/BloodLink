package com.bloodlinkproject.bloodlink.models;

import java.time.LocalDateTime;
import java.util.UUID;

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
public class Reponse {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID reponseId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private Donneur donneur;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "alerte_id")
    private Alerte alerte;

    private LocalDateTime date = LocalDateTime.now();
}
