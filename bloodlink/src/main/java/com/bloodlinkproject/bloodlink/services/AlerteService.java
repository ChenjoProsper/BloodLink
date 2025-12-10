package com.bloodlinkproject.bloodlink.services;

import java.util.List;
import java.util.UUID;

import com.bloodlinkproject.bloodlink.dto.AlerteRequest;
import com.bloodlinkproject.bloodlink.dto.AlerteResult;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.models.Alerte;
import com.bloodlinkproject.bloodlink.models.GroupeSanguin;

public interface AlerteService {
    
    Alerte createAlerte(AlerteRequest alerteRequest);
    
    List<UserResult> recommandeDonne(double latitude, double longitude);
    
    // NOUVELLES MÉTHODES
    List<AlerteResult> getAlertesActives(GroupeSanguin gsang);
    
    List<AlerteResult> getAlertesByMedecin(UUID medecinId);
}