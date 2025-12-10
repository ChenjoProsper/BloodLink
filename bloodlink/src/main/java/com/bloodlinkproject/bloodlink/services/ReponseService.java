package com.bloodlinkproject.bloodlink.services;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.ReponseRequest;
import com.bloodlinkproject.bloodlink.dto.ReponseResult;

@Service
public interface ReponseService {
    
    public ReponseResult accepterDemande(ReponseRequest reponseRequest);
    public String validerAlerte(UUID reponseId);
    public List<ReponseResult> findAllResponse(UUID alerteId);
    public List<ReponseResult> findReponseByMedecin(UUID medecinId);
    public List<ReponseResult> findReponseByDonneur(UUID donneurId);
}
