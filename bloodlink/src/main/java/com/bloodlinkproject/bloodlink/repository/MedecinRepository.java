package com.bloodlinkproject.bloodlink.repository;

import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bloodlinkproject.bloodlink.models.Medecin;

@Repository
public interface MedecinRepository extends JpaRepository<Medecin,UUID> {
    
}
