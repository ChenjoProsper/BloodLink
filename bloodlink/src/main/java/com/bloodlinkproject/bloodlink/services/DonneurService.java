package com.bloodlinkproject.bloodlink.services;

import java.util.List;

import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.DonneurRequest;
import com.bloodlinkproject.bloodlink.dto.UserResult;
import com.bloodlinkproject.bloodlink.models.Donneur;

@Service
public interface DonneurService {

    public UserResult createDonne(DonneurRequest donneurRequest);
    public List<Donneur> afficheAllDonne();
}
