const db = require("../config/db");

exports.getAllEvents = (req, res) => {
  db.query(
    `SELECT e.*, n.name AS ngo_name
     FROM Event e
     JOIN NGO n ON e.ngo_id = n.ngo_id
     ORDER BY e.event_date ASC`,
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.json(result);
    }
  );
};

exports.createEvent = (req, res) => {
  const { ngo_id, title, event_date, location } = req.body;
  db.query(
    "INSERT INTO Event (ngo_id, title, event_date, location) VALUES (?, ?, ?, ?)",
    [ngo_id, title, event_date, location],
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.json({ message: "Event created", id: result.insertId });
    }
  );
};

exports.joinEvent = (req, res) => {
  const { volunteer_id, event_id } = req.body;
  db.query(
    "INSERT INTO Participation (volunteer_id, event_id) VALUES (?, ?)",
    [volunteer_id, event_id],
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.json({ message: "Joined event successfully" });
    }
  );
};