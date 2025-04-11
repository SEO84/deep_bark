package com.deepbark.repository;

import com.deepbark.entity.MixDog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MixDogRepository extends JpaRepository<MixDog, Long> {
    List<MixDog> findByNameEnContainingIgnoreCase(String name);
    List<MixDog> findByNameKoContainingIgnoreCase(String name);
    
    @Query("SELECT m FROM MixDog m WHERE " +
           "LOWER(m.nameEn) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(m.nameKo) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<MixDog> searchMixBreeds(@Param("keyword") String keyword);
    
    List<MixDog> findByBreed1(String breed1);
    List<MixDog> findByBreed2(String breed2);
} 