package com.deepbark.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "pure_dogs")
@Getter
@Setter
public class DogBreed {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name_en", nullable = false)
    private String nameEn;

    @Column(name = "name_ko", nullable = false)
    private String nameKo;

    private String size;
    private String weight;
    private String lifespan;
    private String origin;
} 