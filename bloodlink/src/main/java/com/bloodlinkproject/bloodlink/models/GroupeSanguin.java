package com.bloodlinkproject.bloodlink.models;

public enum GroupeSanguin {
    A_POSITIF("A+"),
    A_NEGATIF("A-"),
    B_POSITIF("B+"),
    B_NEGATIF("B-"),
    O_POSITIF("O+"),
    O_NEGATIF("O-"),
    AB_POSITIF("AB+"),
    AB_NEGATIF("AB-");


    private final String valeur;

    GroupeSanguin(String valeur){
        this.valeur = valeur;
    }

    public String getValeur(){
        return this.valeur;
    }
}
