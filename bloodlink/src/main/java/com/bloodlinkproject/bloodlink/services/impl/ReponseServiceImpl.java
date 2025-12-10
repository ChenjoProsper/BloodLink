package com.bloodlinkproject.bloodlink.services.impl;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.ReponseRequest;
import com.bloodlinkproject.bloodlink.dto.ReponseResult;
import com.bloodlinkproject.bloodlink.mapper.ReponseMapper;
import com.bloodlinkproject.bloodlink.models.Alerte;
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
    private final ReponseMapper reponseMapper;

    @Override
    public ReponseResult accepterDemande(ReponseRequest reponseRequest){

        Alerte alerte = alerteRepository.findById(reponseRequest.getAlerteId()).orElse(null);

        if(alerte.getEtat().equals("TERMINER")){
            throw new RuntimeException("La demande n'est plus en cours");
        }
        Reponse reponse = reponseMapper.toEntity(reponseRequest);
        reponse.getAlerte().setEtat("ACCEPTER");
        alerteRepository.save(reponse.getAlerte());
        reponseRepository.save(reponse);

        return reponseMapper.toDto(reponse);
    }

    @Override
    public String validerAlerte(UUID reponseId){
        Reponse reponse = reponseRepository.findById(reponseId).orElse(null);

        if(reponse.getAlerte().getEtat().equals("TERMINER")){
            throw new RuntimeException("La demande n'est plus en cours");
        }
        reponse.getAlerte().setEtat("TERMINER");
        alerteRepository.save(reponse.getAlerte());
        reponse.getDonneur().setSolde(reponse.getDonneur().getSolde()+reponse.getAlerte().getRemuneration());
        donneurRepository.save(reponse.getDonneur());
        return "alerte "+reponse.getAlerte().getDescription()+ " terminer avec success !!";
    }


    @Override
    public List<ReponseResult> findAllResponse(UUID alerteId){
        return reponseRepository.findByAlerteAlerteId(alerteId).stream().map(reponseMapper::toDto).toList();
    }

    @Override
    public List<ReponseResult> findReponseByMedecin(UUID medecinId){
        // 💡 MODIFICATION: Filtrer uniquement les alertes EN_COURS
        return reponseRepository
            .findByAlerteMedecinUserIdAndAlerteEtat(medecinId, "EN_COURS")
            .stream().map(reponseMapper::toDto).toList();
    }

    @Override
    public List<ReponseResult> findReponseByDonneur(UUID donneurId){
        return reponseRepository.findByDonneurUserId(donneurId).stream().map(reponseMapper::toDto).toList();
    }
}
