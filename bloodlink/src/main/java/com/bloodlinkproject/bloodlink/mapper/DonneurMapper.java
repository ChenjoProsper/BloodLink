package com.bloodlinkproject.bloodlink.mapper;

import org.springframework.stereotype.Component;

import com.bloodlinkproject.bloodlink.dto.DonneurRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.models.Donneur;
import com.bloodlinkproject.bloodlink.models.Role;

@Component
public class DonneurMapper {
    
    public Donneur toEntity(DonneurRequest donneurRequest){

        Donneur donneur = new Donneur();
        donneur.setEmail(donneurRequest.getEmail());
        donneur.setGsang(donneurRequest.getGsang());
        donneur.setLatitude(donneurRequest.getLatitude());
        donneur.setLongitude(donneurRequest.getLongitude());
        donneur.setNom(donneurRequest.getNom());
        donneur.setSexe(donneurRequest.getSexe());
        donneur.setPassword(donneurRequest.getPassword());
        donneur.setRole(Role.DONNEUR);
        donneur.setNumero(donneurRequest.getNuumro());
        return donneur;
    }

    public UserResult toDto(Donneur donneur){

        UserResult userResult = new UserResult();

        userResult.setEmail(donneur.getEmail());
        userResult.setNom(donneur.getNom());
        userResult.setPassword(donneur.getPassword());
        userResult.setSexe(donneur.getSexe());
        userResult.setRole(donneur.getRole().name());
        userResult.setUserId(donneur.getUserId());
        userResult.setNumero(donneur.getNumero());
        userResult.setSolde(donneur.getSolde());
        return userResult;
    }
}
