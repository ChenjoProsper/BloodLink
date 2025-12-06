package com.bloodlinkproject.bloodlink.services;

import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.ReponseRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;

@Service
public interface ReponseService {
    
    public UserResult accepterDemande(ReponseRequest reponseRequest);
    public String validerAlerte(UUID reponseId);
}
