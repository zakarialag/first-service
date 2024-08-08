package com.example.first_service.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ServiceController {

    @GetMapping("/first-service")
    public String home() {
        return "This is first-service";
    }
}
