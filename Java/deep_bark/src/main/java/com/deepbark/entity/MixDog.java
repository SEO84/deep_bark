package com.deepbark.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "mix_dogs")
@Getter
@Setter
public class MixDog {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name_en", nullable = false)
    private String nameEn;

    @Column(name = "name_ko", nullable = false)
    private String nameKo;

    @Column(name = "breed1", nullable = false)
    private String breed1;

    @Column(name = "breed2", nullable = false)
    private String breed2;
} 