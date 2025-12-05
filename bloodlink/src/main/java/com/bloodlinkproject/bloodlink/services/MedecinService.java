package com.bloodlinkproject.bloodlink.services;

import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.MedecinRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;

@Service
public interface MedecinService {
    
    public UserResult createMedecin(MedecinRequest medecinRequest);

}
