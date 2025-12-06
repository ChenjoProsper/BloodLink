package com.bloodlinkproject.bloodlink.services.impl;

import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.AlerteRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.mapper.AlerteMapper;
import com.bloodlinkproject.bloodlink.mapper.DonneurMapper;
import com.bloodlinkproject.bloodlink.models.Alerte;
import com.bloodlinkproject.bloodlink.repository.AlerteRepository;
import com.bloodlinkproject.bloodlink.repository.DonneurRepository;
import com.bloodlinkproject.bloodlink.services.AlerteService;
import com.bloodlinkproject.bloodlink.services.Utils;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AlerteServiceImpl implements AlerteService {

    private final AlerteRepository alerteRepository;
    private final DonneurRepository donneurRepository;
    private final AlerteMapper alerteMapper;
    private final DonneurMapper donneurMapper;
    @Value("${api.key}")
    private String api_key;

    @Override
    public Alerte createAlerte(AlerteRequest alerteRequest){
        Alerte alerte = alerteMapper.toEntity(alerteRequest);

        return alerteRepository.save(alerte);
    }

    @Override
    public List<UserResult> recommandeDonne(UUID alerteId) {
        Alerte alerte = alerteRepository.findById(alerteId).orElse(null);
        double[] position = Utils.getCoordonnes(alerte.getMedecin().getAdresse(),api_key);
        return donneurRepository.findAll().stream()
                .filter(e -> Utils.calculdist(e.getLatitude(), e.getLongitude(), position[0], position[1]) <= 5 && e.getGsang() == alerte.getGsang())
                .map(donneurMapper::toDto)
                .toList();
    }
}
