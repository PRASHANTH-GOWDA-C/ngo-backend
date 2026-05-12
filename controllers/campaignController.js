const db = require("..db/config/db");

exports.getAllCampaigns = (req, res) => {
  console.log("campaigns route hit");
  db.query("SELECT * FROM active_campaigns", (err, result) => {
    if (err) {
      console.error("DB error:", err);
      return res.status(500).json(err);
    }
    console.log("result:", result);
    res.json(result);
  });
};

exports.createCampaign = (req, res) => {
  const { ngo_id, title, description, goal_amount, deadline } = req.body;
  db.query(
    "INSERT INTO Campaign (ngo_id, title, description, goal_amount, deadline) VALUES (?, ?, ?, ?, ?)",
    [ngo_id, title, description, goal_amount, deadline],
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.json({ message: "Campaign created", id: result.insertId });
    }
  );
};