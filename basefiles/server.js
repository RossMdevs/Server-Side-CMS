// There are set routes that should not be touched, these define the actions, run external commands, and wrap the SQL to the DB.
const express = require('express');
const cors = require('cors');
const mysql = require('mysql');
const path = require('path');

const app = express();
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public'))); // Serve static files from 'public' directory

// CHANGE ME TO REFLECT YOUR DATABASE!
const db = mysql.createConnection({
    host: 'localhost',
    user: 'user',
    password: 'passwd!!!',
    database: 'player_data'
});

db.connect(err => {
    if (err) throw err;
    console.log('Connected to the database.'); // Prints a console.log that shows a valid conn to your DB, which is mandatory.
});

// Add a record
app.post('/api/record', (req, res) => {
    const { player_name, fivem_license, warn_ban, conduct_id, reason } = req.body;
    const sql = 'INSERT INTO player_records (player_name, fivem_license, warn_ban, conduct_id, reason) VALUES (?, ?, ?, ?, ?)';
    
    db.query(sql, [player_name, fivem_license, warn_ban, conduct_id, reason], (err, result) => {
        if (err) {
            return res.status(500).send('Error adding record: ' + err.message);
        }
        res.send('Record added successfully.');
    });
});

// Lookup records
app.get('/api/record', (req, res) => {
    const playerName = req.query.player_name;
    const sql = 'SELECT * FROM player_records WHERE player_name LIKE ?';
    
    db.query(sql, [`%${playerName}%`], (err, results) => {
        if (err) {
            return res.status(500).send('Error fetching records: ' + err.message);
        }
        res.json(results);
    });
});

// Delete a record
app.delete('/api/record', (req, res) => {
    const { conduct_id, password } = req.body;
    const your_secure_password = 'your_secure_password'; // Replace with your secure password

    if (password !== your_secure_password) {
        return res.status(403).send('Unauthorized: Incorrect password.');
    }

    const sql = 'DELETE FROM player_records WHERE conduct_id = ?';
    db.query(sql, [conduct_id], (err, result) => {
        if (err) {
            return res.status(500).send('Error deleting record: ' + err.message);
        }
        if (result.affectedRows === 0) {
            return res.status(404).send('No record found with that Conduct ID.');
        }
        res.send('Record deleted successfully.');
    });
});

// Start the server
const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
