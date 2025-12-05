package com.bloodlinkproject.bloodlink.dto;

import java.util.List;
import java.util.UUID;

import com.bloodlinkproject.bloodlink.models.Medecin;

import lombok.Data;

@Data
public class HopitalResult {

    private UUID hopitalId;

    private String nom;

    private String adresse;

    private List<Medecin> medecins;

}
