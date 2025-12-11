package com.bloodlinkproject.bloodlink.dto;

import java.util.UUID;

import com.bloodlinkproject.bloodlink.models.GroupeSanguin;

import lombok.Data;

@Data
public class AlerteResult {

    private UUID alerteId;

    private UUID medecinId;

    private String etat;

    private GroupeSanguin gsang;

    private String adresse;

    private double latitude;

    private double longitude;

    private double remuneration;

    private String description;
}

