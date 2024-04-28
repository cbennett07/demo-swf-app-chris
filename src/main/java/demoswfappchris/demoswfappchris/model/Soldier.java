package demoswfappchris.demoswfappchris.model;
import lombok.*;

import java.io.Serializable;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity(name="Soldier")
@Table(name="soldier")
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class Soldier implements Serializable{
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    private String rank;
}
