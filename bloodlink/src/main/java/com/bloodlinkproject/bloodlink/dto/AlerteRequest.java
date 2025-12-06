package com.bloodlinkproject.bloodlink.dto;

import java.util.UUID;

import com.bloodlinkproject.bloodlink.models.GroupeSanguin;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AlerteRequest {
    
    @NotNull
    private GroupeSanguin gsang;

    @NotNull
    private UUID medecinId;

    private double remuneration;
}
