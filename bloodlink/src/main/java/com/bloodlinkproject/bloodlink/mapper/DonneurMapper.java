package com.bloodlinkproject.bloodlink.mapper;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.bloodlinkproject.bloodlink.dto.DonneurRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.models.Donneur;
import com.bloodlinkproject.bloodlink.models.Role;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class DonneurMapper {
    
    private final PasswordEncoder passwordEncoder;

    public Donneur toEntity(DonneurRequest donneurRequest){

        Donneur donneur = new Donneur();
        donneur.setEmail(donneurRequest.getEmail());
        donneur.setGsang(donneurRequest.getGsang());
        donneur.setLatitude(donneurRequest.getLatitude());
        donneur.setLongitude(donneurRequest.getLongitude());
        donneur.setNom(donneurRequest.getNom());
        donneur.setSexe(donneurRequest.getSexe());
        donneur.setPassword(passwordEncoder.encode(donneurRequest.getPassword()));
        donneur.setRole(Role.DONNEUR);
        donneur.setNumero(donneurRequest.getNumero());
        donneur.setSolde(0.0);
        return donneur;
    }

    public UserResult toDto(Donneur donneur){

        UserResult userResult = new UserResult();

        userResult.setEmail(donneur.getEmail());
        userResult.setNom(donneur.getNom());
        userResult.setSexe(donneur.getSexe());
        userResult.setUserId(donneur.getUserId());
        userResult.setNumero(donneur.getNumero());
        userResult.setSolde(donneur.getSolde());
        userResult.setRole(donneur.getRole());
        userResult.setGsang(donneur.getGsang());
        userResult.setLatitude(donneur.getLatitude());
        userResult.setLongitude(donneur.getLongitude());
        return userResult;
    }
}
