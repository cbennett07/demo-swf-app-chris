# Container Orchestration

## Project Setup

### `Part I - Git Repository Setup`

- Create a repo in Gitlab named `demo-swf-app-<add-your-name>` and clone it down locally:

<p align="center">
  <img src="img/img-001.png" width="100%" title="hover text">
</p>

<p align="center">
  <img src="img/img-002.png" width="100%" title="hover text">
</p>

<p align="center">
  <img src="img/img-003.png" width="100%" title="hover text">
</p>

<p align="center">
  <img src="img/img-004.png" width="100%" title="hover text">
</p>

Change directory to the root of the project:

```shell
cd demo-swf-app-<your-name>
```

### `Part II - Springboot Backend Setup`

Bootstrap a SpringBoot Project:

- Navigate to `start.spring.io` and generate a project with the following settings:

<p align="center">
  <img src="img/img-005.png" width="100%" title="hover text">
</p>

- Unzip the file contents. The files below should be present:

<p align="center">
  <img src="img/img-006.png" width="100%" title="hover text">
</p>

- Copy the files into your git repository folder created in earlier steps:

- `Note`, to make your life easier, only copy the contents of the root folder, and the not the root folder itself.

<p align="center">
  <img src="img/img-007.png" width="100%" title="hover text">
</p>

- The folder structure should look exactly like the image below, with the exception of the name:

<p align="center">
  <img src="img/img-008.png" width="100%" title="hover text">
</p>


### Database Steup

Configure Postgres:

- Install:
```shell
brew install postrgresql

or

sudo apt install postgresql
```

- Connect to the database:

```shell
sudo -u postgres psql
```

- Set a default password, and create the table used for the project called `soldier` and primary key of `id`, and two columns in the table called `name`, and `rank`: This will be used later to insert, and delete soldier information from a simple table.

```sql
ALTER USER postgres WITH PASSWORD 'postgres';

CREATE TABLE soldier( id SERIAL PRIMARY KEY, name VARCHAR(30), rank VARCHAR(30) );
```

- Now, run our Spring Boot app using the `./gradlew bootRun` command, and connect to the database (it should fail) because we have not setup the proper connection in `src/main/resources/application.properties`:

```shell
# set permissions if needed
chmod +x gradlew

./gradlew bootRun
```

- Next, open the `application.properties` file, and append the following key-value pairs to the existging configuration (`do not delete the first line in the file that already exists`):

```json
spring.datasource.url=jdbc:postgresql://localhost:5432/postgres
spring.datasource.username=postgres
spring.datasource.password=postgres
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect
spring.jpa.hibernate.ddl-auto=update
```

- Now, we are going to convert that file to yml, to match how we reference this file in our actual environment (they are interchangable):

```yaml
spring:
  application:
    name: demo-swf-app-joshua
  datasource:
    url: jdbc:postgresql://localhost:5432/postgres
    username: postgres
    password: postgres
    driver-class-name: org.postgresql.Driver
  jpa:
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
    hibernate:
      ddl-auto: update
```

- Next, lets add the postgres dependencies to our `build.gradle` file located in the root directory:

- Before:

```shell
plugins {
	id 'java'
	id 'org.springframework.boot' version '3.2.4'
	id 'io.spring.dependency-management' version '1.1.4'
}

group = 'demo-swf-app-joshua'
version = '0.0.1-SNAPSHOT'

java {
	sourceCompatibility = '17'
}

configurations {
	compileOnly {
		extendsFrom annotationProcessor
	}
}

repositories {
	mavenCentral()
}

dependencies {
	implementation 'org.springframework.boot:spring-boot-starter-data-jdbc'
	implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
	implementation 'org.springframework.boot:spring-boot-starter-web'
	compileOnly 'org.projectlombok:lombok'
	annotationProcessor 'org.projectlombok:lombok'
	testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

tasks.named('test') {
	useJUnitPlatform()
}
```

- Swap out the dependencies in the above `build.gradle` file with this updated list:

```json
dependencies {
    compileOnly 'org.projectlombok:lombok:1.18.22'
    annotationProcessor 'org.projectlombok:lombok:1.18.22'
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    runtimeOnly 'org.postgresql:postgresql'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    implementation 'com.fasterxml.jackson.core:jackson-databind'
}
```

- Let us now check to see if the backend springboot application can connect properly to the postgres database:

```shell
./gradlew bootRun
```

- The following output means you have successfully established a connection to the postgres database (`HikariPool`), Tomcat server on port 8080 has started, and `bootRun` is steadily run at `80% EXECUTING`:

<p align="center">
  <img src="img/img-009.png" width="100%" title="hover text">
</p>

### Frontend Setup

To bootstrap a frontend, we will use React.

- Bootstrap a react project:

```shell
npx create-creact-app frontend
```

<p align="center">
  <img src="img/img-010.png" width="100%" title="hover text">
</p>

```shell
cd frontend/
```

<p align="center">
  <img src="img/img-011.png" width="100%" title="hover text">
</p>

- Test to see if your frontend runs correctly:

```shell
npm run start
```

- Navigate to `localhost:3000` to verify.

- At this point you've bootstrapped a react frontend, a springboot backend, and a postgres database:

### Creating a Functioning Application to Containerize

`Disclaimer:` The purpose of this class is `containerization` and `familiarizing` with the structure of Software factory applications, and how the differant components (`frontend, backend, database`) interact with one-another. At times, troubleshooting outages relies on understanding how application connections work.

At this time, we will briefly describe, then copy and paste code into each file, to demostrate how it works, but we will not be deep diving into how to program in java or react!

####  Backend setup

In the `src/main/java/demoswfappjoshua/demoswfappjoshua` folder, create three directories:

```
- controller
- model
- repository
```

In each folder, create the following files:

```
/controller/SoldierController.java
/model/Soldier.java
/repository/SoldierRepository.java
```

#### Create the `SoldierController.java`

Add the following code to the `SoldierController.java` file, but replace my name in the package name with your name on all occurences:

```java
package demoswfappjosh.demoswfappjosh.controller;

import demoswfappjosh.demoswfappjosh.model.Soldier;
import demoswfappjosh.demoswfappjosh.repository.SoldierRepository;
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
```

- The `SoldierController class` is a part of a Spring Boot application, designed to handle `HTTP requests` related to Soldier entities. The `SoldierController class` utilizes the SoldierRepository for database operations. It follows `RESTful` conventions for `CRUD` operations:

```
POST for creating new resources (insertSoldier)
GET for reading resources (getAllSoldier)
DELETE for deleting resources (deleteSelectedSoldiers)
```

- The controller requires the following dependencies:

`Spring Boot:` A Java-based framework for building web applications.
`Lombok:` A library to reduce boilerplate code in Java classes, used here for `@AllArgsConstructor` to generate a constructor with all fields.

- Below is an explanation of its main functionalities:

`Base Mapping:` All endpoints in this controller are based on the `/api/soldier` path.

`GET /api/soldier/home` Returns a simple message.

`POST /api/soldier/post`:  Sends a `POST` request with a `JSON` body representing a Soldier entity. The Soldier will be saved to the database.

```json
{
  "id": 1,
  "name": "John Doe",
  "rank": "Captain"
}
```

`GET /api/soldier/list`: Fetches all Soldier entities from the database using the SoldierRepository. Making a `GET` request to this endpoint will return a JSON array of all Soldiers in the list:
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "rank": "Captain"
  },
  {
    "id": 2,
    "name": "Jane Smith",
    "rank": "Lieutenant"
  }
]
```

`DELETE /api/soldier/delete`: Sends a `DELETE` request with a JSON body containing an array of Soldier IDs to delete.


```json
[1, 2, 3]
```

#### `Solder.java`:

Add the following code to the model `Soldier.java`, but replace my name in the package name with your name on all occurences:

```java
package demoswfappjosh.demoswfappjosh.model;
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
```

The `Soldier entity class` above is an entity that represents a row that will be inserted, listed, or deleted from our database. Here are a few items in the Soldier entity to be aware of:

- `Table Name:` soldier (table that will be queried)
- `Entity Name:` Soldier (name of our entity)

- `id (Long):` field to insert data into
- `name (String):` field to insert data into
- `rank (String):` field to insert data into

Uses the dependencies:
- `Jakarta Persistence (JPA):` Standard for persisting Java objects in relational databases.
- `Lombok:` A library to reduce boilerplate code in Java classes, used here for generating constructors and getter/setter methods.


#### `SolderRepository.java`:

Add the following code to the model `SoldierRepository.java`, but replace my name in the package name with your name on all occurences:

```java
package demoswfappjoshua.demoswfappjoshua.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import demoswfappjoshua.demoswfappjoshua.model.Soldier;

@Repository
public interface SoldierRepository extends JpaRepository<Soldier, Long> {
}
```

The `SoldierRepository interface` is a part of a Spring Boot application, serving as a repository for the Soldier entity. `Handles database operations` for the Soldier entity. By extending JpaRepository<Soldier, Long>, the SoldierRepository gains access to methods like `save`, `findById`, `findAll`, `deleteById`, `etc.`, without needing to implement these methods manually.

`Spring Data JPA`: Provides an easy and efficient way to interact with the database without writing boilerplate code.
Spring Framework: Provides a powerful framework for building Java-based applications.

The `SoldierRepository interface` can be used to perform CRUD operations on the Soldier entity.

At this time, your backend code should be setup! Let us test it to see if it works:

Manually enter a row into the soldier table:

```shell

# login to pg
sudo -u postgres psql

\c postgres # make sure we are connected to the right db

# insert a row into the database
INSERT INTO soldier (name, rank) VALUES ('your-name', 'your-rank');

# verify the transaction took place
SELECT * FROM soldier;
```

Now, run the backend application to verify that the backend queries the database:

```shell
./gradle bootRun
```

Navigate to:

```
localhost:8080/api/soldier/list (you should see a list of rows)

localhost:8080/api/soldier/home (you should see a simple message)
```

### Frontend

Replace the content of the following files:

`frontend/src/App.js`

```js
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const App = () => {
  const [soldiers, setSoldiers] = useState([]);
  const [name, setName] = useState('');
  const [rank, setRank] = useState('');
  const [selectedSoldiers, setSelectedSoldiers] = useState([]);
  const [showTable, setShowTable] = useState(false);
  const [isFormValid, setIsFormValid] = useState(false); // New state for form validation

  useEffect(() => {
    fetchSoldiers();
  }, []);

  useEffect(() => {
    // Check if both name and rank are filled
    setIsFormValid(name.trim() !== '' && rank.trim() !== '');
  }, [name, rank]);

  const fetchSoldiers = async () => {
    try {
      const response = await axios.get('http://localhost:8080/api/soldier/list');
      setSoldiers(response.data);
      setShowTable(true);
    } catch (error) {
      console.error('Error fetching data:', error);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!name || !rank) {
      alert('Please fill in all fields');
      return;
    }

    try {
      const response = await axios.post('http://localhost:8080/api/soldier/post', { name, rank });
      console.log('Data submitted:', response.data);
      fetchSoldiers(); // Refresh soldiers after submission
      setName('');
      setRank('');
    } catch (error) {
      console.error('Error submitting data:', error);
    }
  };

  const handleCheckboxChange = (id) => {
    const currentIndex = selectedSoldiers.indexOf(id);
    const newSelected = [...selectedSoldiers];

    if (currentIndex === -1) {
      newSelected.push(id);
    } else {
      newSelected.splice(currentIndex, 1);
    }

    setSelectedSoldiers(newSelected);
  };

  const handleDeleteSelected = async () => {
    try {
      const response = await axios.delete('http://localhost:8080/api/soldier/delete', {
        data: selectedSoldiers // Send selected IDs as the request body
      });
      console.log('Delete response:', response.data);
      fetchSoldiers(); // Refresh soldiers after deletion
      setSelectedSoldiers([]); // Clear selected soldiers
    } catch (error) {
      console.error('Error deleting data:', error);
    }
  };

  return (
    <div className="App">
      <div className="App-body">
        <div className="FormContainer">
          <h2>Add Soldier</h2>
          <form onSubmit={handleSubmit} className="SoldierForm">
            <label className="FormLabel">
              Enter Name:
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                className="FormInput"
                required
              />
            </label>
            <br />
            <label className="FormLabel">
              Enter Rank:
              <input
                type="text"
                value={rank}
                onChange={(e) => setRank(e.target.value)}
                className="FormInput"
                required
              />
            </label>
            <br />
            <button type="submit" className="FormButton" disabled={!isFormValid}>
              Add Soldier
            </button>
          </form>
        </div>
        {showTable && (
          <div className="TableContainer">
            <h2>Soldier List</h2>
            <table className="SoldierTable">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Name</th>
                  <th>Rank</th>
                  <th>Delete</th>
                </tr>
              </thead>
              <tbody>
                {soldiers.map(soldier => (
                  <tr key={soldier.id}>
                    <td>{soldier.id}</td>
                    <td>{soldier.name}</td>
                    <td>{soldier.rank}</td>
                    <td>
                      <input
                        type="checkbox"
                        checked={selectedSoldiers.includes(soldier.id)}
                        onChange={() => handleCheckboxChange(soldier.id)}
                      />
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
            <button onClick={handleDeleteSelected} className="deleteButton" disabled={selectedSoldiers.length === 0}>
              Delete Selected
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

export default App;
```

The above `React` application (`App.js`) is a simple soldier management system:

- Users can input a Soldier's name and rank into the form.
Upon submission, the Soldier is added to the system via a POST request to http://localhost:8080/api/soldier/post.

- Upon mounting, the component fetches the list of soldiers from the backend API (http://localhost:8080/api/soldier/list). The list of soldiers is displayed in a table format.

- Users can select Soldiers by checking the checkboxes in the table rows (selectedSoldiers state). Users can select one or more Soldiers by checking the checkboxes. Clicking the "Delete Selected" button triggers a DELETE request to http://localhost:8080/api/soldier/delete, sending the IDs of selected Soldiers to be deleted.


Replace the content of the following files:

`frontend/src/App.js`

```css
body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #101a2b; /* Dark background similar to GitHub's dark mode */
  color: #c9d1d9; /* Text color */
}

.App {
  text-align: center;
  padding-bottom: 15px;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.App-header {
  background-color: #161b22; /* Dark header background */
  min-height: 15vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  font-size: calc(10px + 2vmin);
  color: #58a6ff; /* Header text color */
  width: 100%;
}

.App-logo {
  height: 20vmin;
  pointer-events: none;
  border: 1px solid #30363d; /* Same border as input fields */
}

.App-body {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.FormContainer {
  max-width: 300px;
  width: 100%;
}

.SoldierForm {
  margin-top: 20px;
}

.FormLabel {
  margin-right: 10px;
}

.FormInput {
  width: 100%;
  padding: 10px; /* Add padding to the text boxes */
  font-size: 16px;
  border: 1px solid #30363d; /* Dark border color */
  border-radius: 4px;
  box-sizing: border-box;
  background-color: #0d1117; /* Dark input background */
  color: #c9d1d9; /* Input text color */
}

.FormButton {
  width: 100%;
  margin-top: 10px;
  padding: 10px;
  font-size: 16px;
  background-color: #07305f; /* GitHub's blue color */
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.FormButton:hover {
  background-color: #073c75;
}

.TableContainer {
  margin-top: 2px;
  padding: 10px;
}

.SoldierTable {
  width: 100%;
  border-collapse: collapse;
  margin-top: 2px;
}

.SoldierTable th,
.SoldierTable td {
  border: 1px solid #30363d; /* Dark border color */
  padding: 8px;
  text-align: center; /* Center-align text in table cells */
  border-radius: 8px; /* Rounded corners */
}

.SoldierTable th {
  background-color: #3371c7; /* Dark header background */
  color: #c9d1d9; /* Header text color */
}

.deleteButton {
  background-color: #d73a49; /* GitHub's delete button red color */
  color: white;
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  margin-top: 10px;
}

.deleteButton:disabled {
  background-color: #30363d; /* Dark disabled button color */
  color: #6a737d; /* Disabled button text color */
}

@media (max-width: 768px) {
  .App-header {
    min-height: 10vh;
  }
  
  .App-logo {
    height: 20vmin;
  }
}
```

`Verify the funnctionality of the frontend`

```shell
cd frontend/
```
```shell
# install the axios node module

npm install axios
```

Axios is used to make asynchronous HTTP requests to the backend API.
- axios.get is used to fetch the list of soldiers.
- axios.post is used to add a new Soldier.
- axios.delete is used to delete selected Soldiers.

```shell
npm start

# navigate to see the static page (no data will be displayed yet, until the backend and frontend are built and packaged in an uber jar together.)

# Verify App.js and App.css are functional ()

http://localhost:3000/
```

<p align="center">
  <img src="img/img-012.png" width="100%" title="hover text">
</p>

### Connect the Front and Backends

Let's start by adding new tasks to our gradle build file.

 These tasks will:
 - install any dependencies need for the frontend
 - build the frontend
 - copy the frontend to the correct backend gradle location to be built into an uber jar
 - then clean the front end folder

 These tasks will be executed when running the `./gradlew build` or `./gradlew bootRun` commands, and will essentially generate an uberjar with the front and backend packaged together. At this time, feel free to copy the entire gradle.build file from the demo repo into your build.gradle file. 

 `Important`: replace the group name, with your group name:

 ```java
 plugins {
    id 'java'
    id 'org.springframework.boot' version '3.2.4'
    id 'io.spring.dependency-management' version '1.1.4'
}

group = 'demoswfappjosh'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '17'

repositories {
    mavenCentral()
}

dependencies {
    compileOnly 'org.projectlombok:lombok:1.18.22'
    annotationProcessor 'org.projectlombok:lombok:1.18.22'
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    runtimeOnly 'org.postgresql:postgresql'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
    implementation 'com.fasterxml.jackson.core:jackson-databind'
}

// Task to install frontend dependencies
task installFrontend(type: Exec) {
    inputs.file(file("./frontend/package-lock.json"))
    inputs.file(file("./frontend/package.json"))
    commandLine("npm", "install", "--prefix", "frontend")
    doLast {
        println("We Install")
    }
}

// Task to build frontend
task buildFrontend(type: Exec) {
    dependsOn("installFrontend")
    inputs.dir(file("frontend"))
    outputs.dir(file("frontend/build"))
    commandLine("npm", "run", "build", "--prefix", "frontend")
    doLast {
        println("We built")
    }
}


task copyFrontend(type: Sync) {
    dependsOn("buildFrontend")
    from(file("./frontend/build"))
    into(file("$buildDir/resources/main/static"))
    doLast {
        println("copied built frontend to static resources")
    }
}

tasks.resolveMainClassName {
    dependsOn tasks.copyFrontend
}

jar {
    dependsOn copyFrontend
}

// Define cleanFrontend task
task cleanFrontend(type: Delete) {
    delete(file("./frontend/build"))
    delete(file("./src/main/resources/static"))
}

// Make clean depend on cleanFrontend
clean.dependsOn cleanFrontend

bootJar.enabled = false
```

Run the following command and navigate to localhost:8080 to view the application:

```shell
./gradlew build
```

### `Part VI - Containerize the application`

```Dockerfile
FROM openjdk:17-jdk-slim AS build
WORKDIR /app
COPY . .

RUN apt-get update
RUN apt-get install -y npm
RUN ./gradlew build

# Stage 2: Create the final image
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/build/libs/demo-swf-app-josh-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
```
