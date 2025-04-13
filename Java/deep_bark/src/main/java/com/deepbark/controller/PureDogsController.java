package com.deepbark.controller;

import com.deepbark.entity.PureDogs;
import com.deepbark.repository.PureDogsRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/pure-dogs")
@CrossOrigin(origins = "*")
public class PureDogsController {

    private static final Logger logger = LoggerFactory.getLogger(PureDogsController.class);

    @Autowired
    private PureDogsRepository pureDogsRepository;

    @GetMapping
    public ResponseEntity<List<PureDogs>> getAllPureDogs() {
        logger.info("Fetching all pure dogs - Request received");
        try {
            List<PureDogs> breeds = pureDogsRepository.findAll();
            logger.info("Found {} pure dogs", breeds.size());
            return ResponseEntity.ok()
                    .header("Content-Type", "application/json")
                    .body(breeds);
        } catch (Exception e) {
            logger.error("Error fetching pure dogs: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError().build();
        }
    }

    @GetMapping("/search")
    public ResponseEntity<List<PureDogs>> searchPureDogs(@RequestParam String keyword) {
        logger.info("Searching pure dogs with keyword: {}", keyword);
        List<PureDogs> breeds = pureDogsRepository.searchBreeds(keyword);
        return ResponseEntity.ok(breeds);
    }

    @GetMapping("/name-en/{name}")
    public ResponseEntity<List<PureDogs>> getPureDogsByNameEn(@PathVariable String name) {
        logger.info("Fetching pure dogs by English name: {}", name);
        List<PureDogs> breeds = pureDogsRepository.findByNameEn(name);
        return ResponseEntity.ok(breeds);
    }

    @GetMapping("/name-ko/{name}")
    public ResponseEntity<List<PureDogs>> getPureDogsByNameKo(@PathVariable String name) {
        logger.info("Fetching pure dogs by Korean name: {}", name);
        List<PureDogs> breeds = pureDogsRepository.findByNameKo(name);
        return ResponseEntity.ok(breeds);
    }

    @GetMapping("/size-en/{size}")
    public ResponseEntity<List<PureDogs>> getPureDogsBySizeEn(@PathVariable String size) {
        logger.info("Fetching pure dogs by English size: {}", size);
        List<PureDogs> breeds = pureDogsRepository.findBySizeEn(size);
        return ResponseEntity.ok(breeds);
    }

    @GetMapping("/size-ko/{size}")
    public ResponseEntity<List<PureDogs>> getPureDogsBySizeKo(@PathVariable String size) {
        logger.info("Fetching pure dogs by Korean size: {}", size);
        List<PureDogs> breeds = pureDogsRepository.findBySizeKo(size);
        return ResponseEntity.ok(breeds);
    }

    @GetMapping("/origin-en/{origin}")
    public ResponseEntity<List<PureDogs>> getPureDogsByOriginEn(@PathVariable String origin) {
        logger.info("Fetching pure dogs by English origin: {}", origin);
        List<PureDogs> breeds = pureDogsRepository.findByOriginEn(origin);
        return ResponseEntity.ok(breeds);
    }

    @GetMapping("/origin-ko/{origin}")
    public ResponseEntity<List<PureDogs>> getPureDogsByOriginKo(@PathVariable String origin) {
        logger.info("Fetching pure dogs by Korean origin: {}", origin);
        List<PureDogs> breeds = pureDogsRepository.findByOriginKo(origin);
        return ResponseEntity.ok(breeds);
    }
} 