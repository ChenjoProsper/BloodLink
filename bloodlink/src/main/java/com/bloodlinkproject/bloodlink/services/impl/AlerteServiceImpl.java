package com.bloodlinkproject.bloodlink.services.impl;

import java.util.List;
import java.util.stream.Collectors;

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

    @Override
    public Alerte createAlerte(AlerteRequest alerteRequest){
        Alerte alerte = alerteMapper.toEntity(alerteRequest);
        alerte.setEtat("EN_COURS"); // Définir l'état par défaut
        return alerteRepository.save(alerte);
    }

    @Override
    public List<UserResult> recommandeDonne(double latitude, double longitude) {
        return donneurRepository.findAll().stream()
                .filter(e -> Utils.calculdist(e.getLatitude(), e.getLongitude(), latitude, longitude) <= 5)
                .map(donneurMapper::toDto)
                .toList();
    }

    // NOUVELLES IMPLÉMENTATIONS
    @Override
    public List<Alerte> getAlertesActives() {
        return alerteRepository.findAll().stream()
                .filter(alerte -> "EN_COURS".equals(alerte.getEtat()))
                .collect(Collectors.toList());
    }

    @Override
    public List<Alerte> getAlertesByMedecin(String medecinId) {
        return alerteRepository.findAll().stream()
                .filter(alerte -> medecinId.equals(alerte.getMedecin().getUserId()))
                .collect(Collectors.toList());
    }
}