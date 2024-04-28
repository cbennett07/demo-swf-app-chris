package demoswfappchris.demoswfappchris.controller;

import demoswfappchris.demoswfappchris.model.Soldier;
import demoswfappchris.demoswfappchris.repository.SoldierRepository;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@AllArgsConstructor
@RequestMapping("/api/soldier") // Base mapping for all methods in this controller
public class SoldierController {
    private final SoldierRepository soldierRepository;

    @GetMapping("/home")
    public String home() {
        return "Demo CRUD App Deployment Class for Cohort 7";
    }

    @PostMapping("/post")
    public ResponseEntity<Void> insertSoldier(@RequestBody Soldier soldier) {
        System.out.println("Received Soldier: " + soldier);

        soldierRepository.save(soldier);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/list")
    public ResponseEntity<List<Soldier>> getAllSoldier() {
        List<Soldier> soldierList = soldierRepository.findAll();
        return ResponseEntity.ok().body(soldierList);
    }

    @DeleteMapping("/delete") 
    public ResponseEntity<Void> deleteSelectedSoldiers(@RequestBody List<Long> soldierIds) {
        soldierIds.forEach(id -> {
            soldierRepository.deleteById(id);
        });
        return ResponseEntity.noContent().build();
    }
}

