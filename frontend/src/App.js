import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';
import LogoImage from './download.jpg';

const baseUrl = process.env.API_BASE_URL || 'http://localhost:8080/api/soldier';

const Logo = () => (
  <div className="LogoContainer">
    <img src={LogoImage} alt="Logo" className="LogoImage" />
  </div>
);

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
      const response = await axios.get(`${baseUrl}/list`);
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
      const response = await axios.post(`${baseUrl}/post`, { name, rank });
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
      const response = await axios.delete(`${baseUrl}/delete`, {
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
        {/* Logo Component */}
        <Logo />
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
