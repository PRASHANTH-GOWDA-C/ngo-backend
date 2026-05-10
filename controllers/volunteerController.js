const db = require("../config/db");

exports.registerVolunteer = (req, res) => {
  const { name, email, skill } = req.body;
  db.query(
    "INSERT INTO Volunteer (name, email, skill) VALUES (?, ?, ?)",
    [name, email, skill],
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.json({ message: "Volunteer registered", id: result.insertId });
    }
  );
};

exports.getAllVolunteers = (req, res) => {
  db.query("SELECT * FROM Volunteer", (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
};