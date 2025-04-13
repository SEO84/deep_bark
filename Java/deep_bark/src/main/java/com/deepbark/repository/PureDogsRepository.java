package com.deepbark.repository;

import com.deepbark.entity.PureDogs;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PureDogsRepository extends JpaRepository<PureDogs, Long> {
    @Query("SELECT d FROM PureDogs d WHERE d.nameEn LIKE %:name%")
    List<PureDogs> findByNameEn(@Param("name") String name);
    
    @Query("SELECT d FROM PureDogs d WHERE d.nameKo LIKE %:name%")
    List<PureDogs> findByNameKo(@Param("name") String name);
    
    @Query("SELECT d FROM PureDogs d WHERE " +
           "d.nameEn LIKE %:keyword% OR " +
           "d.nameKo LIKE %:keyword%")
    List<PureDogs> searchBreeds(@Param("keyword") String keyword);
    
    @Query("SELECT d FROM PureDogs d WHERE d.sizeEn LIKE %:size%")
    List<PureDogs> findBySizeEn(@Param("size") String size);
    
    @Query("SELECT d FROM PureDogs d WHERE d.sizeKo LIKE %:size%")
    List<PureDogs> findBySizeKo(@Param("size") String size);
    
    @Query("SELECT d FROM PureDogs d WHERE d.originEn LIKE %:origin%")
    List<PureDogs> findByOriginEn(@Param("origin") String origin);
    
    @Query("SELECT d FROM PureDogs d WHERE d.originKo LIKE %:origin%")
    List<PureDogs> findByOriginKo(@Param("origin") String origin);
} 