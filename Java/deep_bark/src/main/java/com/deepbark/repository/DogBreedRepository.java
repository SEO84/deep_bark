package com.deepbark.repository;

import com.deepbark.entity.DogBreed;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface DogBreedRepository extends JpaRepository<DogBreed, Long> {
    List<DogBreed> findByNameEnContainingIgnoreCase(String name);
    List<DogBreed> findByNameKoContainingIgnoreCase(String name);
    
    @Query("SELECT d FROM DogBreed d WHERE " +
           "LOWER(d.nameEn) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(d.nameKo) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<DogBreed> searchBreeds(@Param("keyword") String keyword);
    
    List<DogBreed> findBySize(String size);
    List<DogBreed> findByOrigin(String origin);
} 