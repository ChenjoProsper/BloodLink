package com.bloodlinkproject.bloodlink.mapper;

import org.springframework.stereotype.Component;

import com.bloodlinkproject.bloodlink.dto.AlerteRequest;
import com.bloodlinkproject.bloodlink.dto.AlerteResult;
import com.bloodlinkproject.bloodlink.models.Alerte;
import com.bloodlinkproject.bloodlink.models.Medecin;
import com.bloodlinkproject.bloodlink.repository.MedecinRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class AlerteMapper {
    
    private final MedecinRepository medecinRepository;

    public Alerte toEntity(AlerteRequest alerteRequest){

        Alerte alerte = new Alerte();

        alerte.setRemuneration(alerteRequest.getRemuneration());
        alerte.setGsang(alerteRequest.getGsang());
        Medecin medecin = medecinRepository.findById(alerteRequest.getMedecinId()).orElse(null);
        alerte.setMedecin(medecin);
        alerte.setDescription("Besoin de sang "+alerteRequest.getGsang()+ " a l'adresse "+medecin.getAdresse());
        return alerte;
    }

    public AlerteResult toDto(Alerte alerte){
        AlerteResult alerteResult = new AlerteResult();
        alerteResult.setAdresse(alerte.getMedecin().getAdresse());
        alerteResult.setDescription(alerte.getDescription());
        alerteResult.setRemuneration(alerte.getRemuneration());
        alerteResult.setAlerteId(alerte.getAlerteId());
        return alerteResult;
    }

}
