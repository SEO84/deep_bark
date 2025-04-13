package com.deepbark.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@Entity
@Table(name = "pure_dogs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties(ignoreUnknown = true)
public class PureDogs {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name_en", nullable = false)
    private String nameEn;

    @Column(name = "name_ko", nullable = false)
    private String nameKo;

    @Column(name = "size_en")
    private String sizeEn;

    @Column(name = "size_ko")
    private String sizeKo;

    @Column(name = "weight")
    private String weight;

    @Column(name = "lifespan")
    private String lifespan;

    @Column(name = "origin_en")
    private String originEn;

    @Column(name = "origin_ko")
    private String originKo;
}