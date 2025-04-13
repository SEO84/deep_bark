package com.deepbark.controller;

import com.deepbark.entity.MixDogs;
import com.deepbark.repository.MixDogRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/mix-dogs")
@CrossOrigin(origins = "*")
public class MixDogController {

    private static final Logger logger = LoggerFactory.getLogger(MixDogController.class);

    @Autowired
    private MixDogRepository mixDogRepository;

    @GetMapping
    public ResponseEntity<List<MixDogs>> getAllMixDogs() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        logger.info("Current authentication: {}", auth);
        logger.info("Current authorities: {}", auth.getAuthorities());
        
        logger.info("Fetching all mix dogs");
        List<MixDogs> mixDogs = mixDogRepository.findAll();
        return ResponseEntity.ok(mixDogs);
    }

    @GetMapping("/search")
    public ResponseEntity<List<MixDogs>> searchMixDogs(@RequestParam String keyword) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        logger.info("Current authentication: {}", auth);
        logger.info("Current authorities: {}", auth.getAuthorities());
        
        logger.info("Searching mix dogs with keyword: {}", keyword);
        List<MixDogs> mixDogs = mixDogRepository.searchMixBreeds(keyword);
        return ResponseEntity.ok(mixDogs);
    }

    @GetMapping("/name-en/{name}")
    public ResponseEntity<List<MixDogs>> getMixDogsByNameEn(@PathVariable String name) {
        logger.info("Fetching mix dogs by English name: {}", name);
        List<MixDogs> mixDogs = mixDogRepository.findByNameEn(name);
        return ResponseEntity.ok(mixDogs);
    }

    @GetMapping("/name-ko/{name}")
    public ResponseEntity<List<MixDogs>> getMixDogsByNameKo(@PathVariable String name) {
        logger.info("Fetching mix dogs by Korean name: {}", name);
        List<MixDogs> mixDogs = mixDogRepository.findByNameKo(name);
        return ResponseEntity.ok(mixDogs);
    }

    @GetMapping("/breed1/{breedName}")
    public ResponseEntity<List<MixDogs>> getMixDogsByBreed1(@PathVariable String breedName) {
        logger.info("Fetching mix dogs by breed1: {}", breedName);
        List<MixDogs> mixDogs = mixDogRepository.findByBreed1(breedName);
        return ResponseEntity.ok(mixDogs);
    }

    @GetMapping("/breed2/{breedName}")
    public ResponseEntity<List<MixDogs>> getMixDogsByBreed2(@PathVariable String breedName) {
        logger.info("Fetching mix dogs by breed2: {}", breedName);
        List<MixDogs> mixDogs = mixDogRepository.findByBreed2(breedName);
        return ResponseEntity.ok(mixDogs);
    }
} 