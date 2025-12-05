package com.bloodlinkproject.bloodlink.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import lombok.Data;

@Entity
@Data
public class Donneur extends User {
    
    @Column(name = "groupe_sanguin",nullable = false)
    private String gsang;

    @Column(name = "latitude")
    private Long latitude;

    @Column(name = "longitude")
    private Long longitude;

}
