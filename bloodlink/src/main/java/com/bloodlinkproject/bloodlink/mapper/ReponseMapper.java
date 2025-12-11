package com.bloodlinkproject.bloodlink.mapper;

import org.springframework.stereotype.Component;

import com.bloodlinkproject.bloodlink.dto.ReponseRequest;
import com.bloodlinkproject.bloodlink.dto.ReponseResult;
import com.bloodlinkproject.bloodlink.models.Alerte;
import com.bloodlinkproject.bloodlink.models.Donneur;
import com.bloodlinkproject.bloodlink.models.Reponse;
import com.bloodlinkproject.bloodlink.repository.AlerteRepository;
import com.bloodlinkproject.bloodlink.repository.DonneurRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class ReponseMapper {
    
    private final DonneurRepository donneurRepository;
    private final AlerteMapper alerteMapper;
    private final DonneurMapper donneurMapper;
    private final AlerteRepository alerteRepository;


    public Reponse toEntity(ReponseRequest reponseRequest){
        Reponse reponse = new Reponse();
        Donneur donneur = donneurRepository.findById(reponseRequest.getDonneurId()).orElse(null);
        Alerte alerte = alerteRepository.findById(reponseRequest.getAlerteId()).orElse(null);
        reponse.setAlerte(alerte);
        reponse.setDonneur(donneur);
        return reponse;
    }
    public ReponseResult toDto(Reponse reponse){
        ReponseResult reponseResult = new ReponseResult();
        reponseResult.setAlerte(alerteMapper.toDto(reponse.getAlerte()));
        reponseResult.setDonneur(donneurMapper.toDto(reponse.getDonneur()));
        reponseResult.setReponseId(reponse.getReponseId());
        reponseResult.setDateReponse(reponse.getDate());

        return reponseResult;
    }
}
