package com.bloodlinkproject.bloodlink.services.impl;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.ReponseRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.mapper.DonneurMapper;
import com.bloodlinkproject.bloodlink.models.Alerte;
import com.bloodlinkproject.bloodlink.models.Donneur;
import com.bloodlinkproject.bloodlink.models.Reponse;
import com.bloodlinkproject.bloodlink.repository.AlerteRepository;
import com.bloodlinkproject.bloodlink.repository.DonneurRepository;
import com.bloodlinkproject.bloodlink.repository.ReponseRepository;
import com.bloodlinkproject.bloodlink.services.ReponseService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ReponseServiceImpl implements ReponseService {
    private final AlerteRepository alerteRepository;
    private final DonneurRepository donneurRepository;
    private final ReponseRepository reponseRepository;
    private final DonneurMapper donneurMapper;

    @Override
    public UserResult accepterDemande(ReponseRequest reponseRequest){

        Alerte alerte = alerteRepository.findById(reponseRequest.getAlerteId()).orElse(null);

        if(alerte.getEtat().equals("TERMINER")){
            throw new RuntimeException("La demande n'est plus en cours");
        }

        Donneur donneur = donneurRepository.findById(reponseRequest.getDonneurId()).orElse(null);

        Reponse reponse = new Reponse();
        reponse.setAlerte(alerte);
        reponse.setDonneur(donneur);

        reponseRepository.save(reponse);

        return donneurMapper.toDto(donneur);
    }

    @Override
    public String validerAlerte(UUID reponseId){
        Reponse reponse = reponseRepository.findById(reponseId).orElse(null);

        reponse.getAlerte().setEtat("TERMINER");
        alerteRepository.save(reponse.getAlerte());
        reponse.getDonneur().setSolde(reponse.getDonneur().getSolde()+reponse.getAlerte().getRemuneration());
        donneurRepository.save(reponse.getDonneur());
        return "alerte "+reponse.getAlerte().getDescription()+ " terminer avec success !!";
    }
}
