package com.bloodlinkproject.bloodlink.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import com.bloodlinkproject.bloodlink.models.Alerte;
import com.bloodlinkproject.bloodlink.models.GroupeSanguin;

@Repository
public interface AlerteRepository extends JpaRepository<Alerte,UUID> {
    
    List<Alerte> findByEtatAndGsang(String etat, GroupeSanguin gsang);

    List<Alerte> findByMedecinUserId(UUID userId);

    @Query("SELECT DISTINCT a FROM Alerte a JOIN FETCH a.medecin m LEFT JOIN FETCH a.reponses r WHERE m.userId = :medecinId")
    List<Alerte> findAlertesByMedecinOptimized(UUID medecinId);
}
