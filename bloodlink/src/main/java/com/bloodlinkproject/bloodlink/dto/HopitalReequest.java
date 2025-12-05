package com.bloodlinkproject.bloodlink.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class HopitalReequest {
    
    @NotNull
    private String nom;

    @NotNull
    private String adresse;
}
