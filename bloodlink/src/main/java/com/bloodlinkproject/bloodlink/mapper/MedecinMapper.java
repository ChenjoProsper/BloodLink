package com.bloodlinkproject.bloodlink.mapper;

import org.springframework.stereotype.Component;

import com.bloodlinkproject.bloodlink.dto.MedecinRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.models.Donneur;
import com.bloodlinkproject.bloodlink.models.Hopital;
import com.bloodlinkproject.bloodlink.models.Medecin;
import com.bloodlinkproject.bloodlink.models.Role;
import com.bloodlinkproject.bloodlink.repository.HopitalRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class MedecinMapper {
    
    private final HopitalRepository hopitalRepository;
    

    public Medecin toEntity(MedecinRequest medecinRequest){
        Medecin medecin = new Medecin();
        medecin.setEmail(medecinRequest.getEmail());
        medecin.setNom(medecinRequest.getNom());
        medecin.setPassword(medecinRequest.getPassword());
        medecin.setPrenom(medecinRequest.getPrenom());
        medecin.setRole(Role.MEDECIN);

        Hopital hopital = hopitalRepository.findById(medecinRequest.getHopitalId()).orElse(null);
        medecin.setHopital(hopital);
        return medecin;
    }

    public UserResult toDto(Medecin medecin){

        UserResult userResult = new UserResult();

        userResult.setEmail(medecin.getEmail());
        userResult.setNom(medecin.getNom());
        userResult.setPassword(medecin.getPassword());
        userResult.setPrenom(medecin.getPrenom());
        userResult.setRole(medecin.getRole().name());
        userResult.setUserId(medecin.getUserId());
        return userResult;
    }
}
