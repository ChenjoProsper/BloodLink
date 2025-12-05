package com.bloodlinkproject.bloodlink.services;

import org.springframework.stereotype.Service;

import com.bloodlinkproject.bloodlink.dto.UserAuth;
import com.bloodlinkproject.bloodlink.models.User;

@Service
public interface UserService {
    
    public User authentificationUser(UserAuth userAuth);
}
