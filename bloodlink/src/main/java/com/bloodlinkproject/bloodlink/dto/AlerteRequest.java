package com.bloodlinkproject.bloodlink.dto;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AlerteRequest {
    
    @NotNull
    private String gsang;

    @NotNull
    private UUID medecinId;

    private Long remuneration;
}
