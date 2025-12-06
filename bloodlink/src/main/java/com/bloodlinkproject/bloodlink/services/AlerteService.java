package com.bloodlinkproject.bloodlink.services;

import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.AlerteRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.models.Alerte;

@Service
public interface AlerteService {
    
    public Alerte createAlerte(AlerteRequest alerteRequest);
    public List<UserResult> recommandeDonne(UUID alertId);
}
