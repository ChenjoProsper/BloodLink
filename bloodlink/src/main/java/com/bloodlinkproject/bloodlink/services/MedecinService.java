package com.bloodlinkproject.bloodlink.services;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.MedecinRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.models.Medecin;

@Service
public interface MedecinService {
    
    public UserResult createMedecin(MedecinRequest medecinRequest);
    public List<Medecin> afficheAllDonne();
    public double[] getCoordonnesByMedecin(UUID medecinId);
    public double[] getCoordonnesByAdresse(String adresse);
}
