package com.bloodlinkproject.bloodlink.repository;

import java.util.List;
import java.util.UUID;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.bloodlinkproject.bloodlink.models.Reponse;

@Repository
public interface ReponseRepository extends JpaRepository<Reponse,UUID> {
    List<Reponse> findByAlerteAlerteId(UUID alerte);
    List<Reponse> findByAlerteMedecinUserId(UUID userId);
    List<Reponse> findByDonneurUserId(UUID userId);
    List<Reponse> findByAlerteMedecinUserIdAndAlerteEtat(UUID userId, String etat);

}
