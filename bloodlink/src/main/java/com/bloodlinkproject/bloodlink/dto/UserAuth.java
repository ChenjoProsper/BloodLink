package com.bloodlinkproject.bloodlink.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UserAuth {
    
    @NotNull
    @Email
    private String email;

    @NotNull
    private String password;
}
