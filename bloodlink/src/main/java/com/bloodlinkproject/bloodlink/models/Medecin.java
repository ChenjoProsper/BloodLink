package com.bloodlinkproject.bloodlink.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(callSuper = true)
public class Medecin extends User {
    
    @Column(name = "adresse",nullable = false)
    private String adresse;
}
