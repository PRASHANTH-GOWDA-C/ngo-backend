const db = require("../config/db");

exports.getAllDonors = (req, res) => {
  db.query("SELECT * FROM Donor", (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
};

exports.createDonor = (req, res) => {
  const { name, email, phone, type } = req.body;
  db.query(
    "INSERT INTO Donor (name, email, phone, type) VALUES (?, ?, ?, ?)",
    [name, email, phone, type],
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.json({ message: "Donor created", id: result.insertId });
    }
  );
};