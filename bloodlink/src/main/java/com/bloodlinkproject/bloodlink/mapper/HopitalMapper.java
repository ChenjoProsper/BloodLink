package com.bloodlinkproject.bloodlink.mapper;

import org.springframework.stereotype.Component;

import com.bloodlinkproject.bloodlink.dto.HopitalReequest;
import com.bloodlinkproject.bloodlink.dto.HopitalResult;
import com.bloodlinkproject.bloodlink.models.Hopital;

@Component
public class HopitalMapper {
    
    
    public Hopital toEntity(HopitalReequest hopitalReequest){
        Hopital hopital = new Hopital();
        hopital.setNom(hopitalReequest.getNom());
        hopital.setAdresse(hopitalReequest.getAdresse());
        return hopital;
    }

    public HopitalResult toDto(Hopital hopital){

        HopitalResult hopitalResult = new HopitalResult();

        hopitalResult.setAdresse(hopital.getAdresse());
        hopitalResult.setHopitalId(hopital.getHopitalId());
        hopitalResult.setNom(hopital.getNom());
        hopitalResult.setMedecins(hopital.getMedecins());


        return hopitalResult;
    }
}
