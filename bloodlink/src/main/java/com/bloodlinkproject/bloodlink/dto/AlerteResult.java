package com.bloodlinkproject.bloodlink.dto;

import java.util.UUID;

import lombok.Data;

@Data
public class AlerteResult {

    private UUID alerteId;

    private String adresse;

    private double remuneration;

    private String description;
}

