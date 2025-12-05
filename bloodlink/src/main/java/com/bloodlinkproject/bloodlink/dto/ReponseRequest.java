package com.bloodlinkproject.bloodlink.dto;

import java.util.UUID;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ReponseRequest {
    
    @NotNull
    private UUID donneurId;

    @NotNull
    private UUID alerteId;
}
