package com.deepbark.controller;

import com.deepbark.entity.DogBreed;
import com.deepbark.repository.DogBreedRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

@RestController
@RequestMapping("/api/breeds")
@CrossOrigin(origins = "*")
public class DogBreedController {

    private static final Logger logger = LoggerFactory.getLogger(DogBreedController.class);

    @Autowired
    private DogBreedRepository dogBreedRepository;

    @GetMapping
    public ResponseEntity<List<DogBreed>> getAllBreeds() {
        logger.info("GET /api/breeds 요청 수신");
        List<DogBreed> breeds = dogBreedRepository.findAll();
        logger.info("견종 데이터 조회 완료: {}개", breeds.size());
        return ResponseEntity.ok(breeds);
    }

    @GetMapping("/search")
    public ResponseEntity<List<DogBreed>> searchBreeds(@RequestParam String keyword) {
        logger.info("GET /api/breeds/search 요청 수신 - 키워드: {}", keyword);
        List<DogBreed> breeds = dogBreedRepository.searchBreeds(keyword);
        return ResponseEntity.ok(breeds);
    }

    @GetMapping("/size/{size}")
    public ResponseEntity<List<DogBreed>> getBreedsBySize(@PathVariable String size) {
        logger.info("GET /api/breeds/size/{} 요청 수신", size);
        List<DogBreed> breeds = dogBreedRepository.findBySize(size);
        return ResponseEntity.ok(breeds);
    }

    @GetMapping("/origin/{origin}")
    public ResponseEntity<List<DogBreed>> getBreedsByOrigin(@PathVariable String origin) {
        logger.info("GET /api/breeds/origin/{} 요청 수신", origin);
        List<DogBreed> breeds = dogBreedRepository.findByOrigin(origin);
        return ResponseEntity.ok(breeds);
    }
} 