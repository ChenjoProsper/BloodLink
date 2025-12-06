package com.bloodlinkproject.bloodlink.services.impl;

import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.MedecinRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.mapper.MedecinMapper;
import com.bloodlinkproject.bloodlink.models.Medecin;
import com.bloodlinkproject.bloodlink.repository.MedecinRepository;
import com.bloodlinkproject.bloodlink.services.MedecinService;
import com.bloodlinkproject.bloodlink.services.Utils;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MedecinServiceImpl implements MedecinService {

    private final MedecinRepository medecinRepository;
    private final MedecinMapper medecinMapper;
    
    @Value("${api.key}")
    private String api_key;
    
    @Override
    public UserResult createMedecin(MedecinRequest medecinRequest){
        Medecin user = medecinMapper.toEntity(medecinRequest);

        medecinRepository.save(user);
        return medecinMapper.toDto(user);
    }

    @Override
    public List<Medecin> afficheAllDonne(){
        return medecinRepository.findAll();
    }

    @Override
    public double[] getCoordonnesByMedecin(UUID medecinId){
        Medecin medecin = medecinRepository.findById(medecinId).orElse(null);
        return Utils.getCoordonnes(medecin.getAdresse(), api_key);
    }

    @Override
    public double[] getCoordonnesByAdresse(String adresse){
        return Utils.getCoordonnes(adresse, api_key);
    }
}
