package com.bloodlinkproject.bloodlink.mapper;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import com.bloodlinkproject.bloodlink.dto.MedecinRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.models.Medecin;
import com.bloodlinkproject.bloodlink.models.Role;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class MedecinMapper {

    private final PasswordEncoder passwordEncoder;

    public Medecin toEntity(MedecinRequest medecinRequest){
        Medecin medecin = new Medecin();
        medecin.setEmail(medecinRequest.getEmail());
        medecin.setNom(medecinRequest.getNom());
        medecin.setPassword(passwordEncoder.encode(medecinRequest.getPassword()));
        medecin.setSexe(medecinRequest.getSexe());
        medecin.setRole(Role.MEDECIN);
        medecin.setAdresse(medecinRequest.getAdresse());
        medecin.setNumero(medecinRequest.getNumero());
        return medecin;
    }

    public UserResult toDto(Medecin medecin){
        UserResult userResult = new UserResult();
        userResult.setEmail(medecin.getEmail());
        userResult.setNom(medecin.getNom());
        userResult.setPassword(medecin.getPassword());
        userResult.setSexe(medecin.getSexe());
        userResult.setRole(medecin.getRole().name());
        userResult.setUserId(medecin.getUserId());
        userResult.setNumero(medecin.getNumero());
        return userResult;
    }
}
