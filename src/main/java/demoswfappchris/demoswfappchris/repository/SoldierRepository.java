package demoswfappchris.demoswfappchris.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import demoswfappchris.demoswfappchris.model.Soldier;

@Repository
public interface SoldierRepository extends JpaRepository<Soldier, Long> {
}

