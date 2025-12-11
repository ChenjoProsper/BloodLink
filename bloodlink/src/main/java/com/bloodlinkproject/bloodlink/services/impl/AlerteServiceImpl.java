package com.bloodlinkproject.bloodlink.services.impl;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.AlerteRequest;
import com.bloodlinkproject.bloodlink.dto.AlerteResult;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.mapper.AlerteMapper;
import com.bloodlinkproject.bloodlink.mapper.DonneurMapper;
import com.bloodlinkproject.bloodlink.models.Alerte;
import com.bloodlinkproject.bloodlink.models.GroupeSanguin;
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
    public List<AlerteResult> getAlertesActives(GroupeSanguin gsang) {
        return alerteRepository.findByEtatAndGsang("EN_COURS", gsang)
                        .stream().map(alerteMapper::toDto).toList();
            }

    @Override
    public List<AlerteResult> getAlertesByMedecin(UUID medecinId) {
        return alerteRepository.findAlertesByMedecinOptimized(medecinId)
                        .stream().map(alerteMapper::toDto).toList();
    }
}