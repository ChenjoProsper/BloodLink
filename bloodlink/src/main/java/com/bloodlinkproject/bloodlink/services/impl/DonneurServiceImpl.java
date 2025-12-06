package com.bloodlinkproject.bloodlink.services.impl;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.DonneurRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.mapper.DonneurMapper;
import com.bloodlinkproject.bloodlink.models.Donneur;
import com.bloodlinkproject.bloodlink.repository.DonneurRepository;
import com.bloodlinkproject.bloodlink.services.DonneurService;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class DonneurServiceImpl implements DonneurService {
    
    private final DonneurRepository donneurRepository;
    private final DonneurMapper donneurMapper;
    
    @Override
    public UserResult createDonne(DonneurRequest donneurRequest){
        Donneur user = donneurMapper.toEntity(donneurRequest);

        donneurRepository.save(user);
        return donneurMapper.toDto(user);
    }

    @Override
    public List<Donneur> afficheAllDonne(){
        return donneurRepository.findAll();
    }

    @Override
    public String updatePosition(UUID donneurId,double latitude,double longitude){
        Donneur donneur = donneurRepository.findById(donneurId).orElse(null);
        donneur.setLatitude(latitude);
        donneur.setLongitude(longitude);

        return "Position mis a jour avec success !!";
    }
}
