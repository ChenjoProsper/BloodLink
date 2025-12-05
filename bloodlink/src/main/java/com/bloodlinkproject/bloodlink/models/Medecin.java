package com.bloodlinkproject.bloodlink.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import lombok.Data;

@Entity
@Data
public class Medecin extends User {
    
    @Column(name = "adresse",nullable = false)
    private String adresse;
}
