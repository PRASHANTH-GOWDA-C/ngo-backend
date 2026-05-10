const db = require("../config/db");

exports.donate = (req, res) => {
  const { donor_id, campaign_id, pool_id, amount } = req.body;
  db.query(
    "INSERT INTO Donation (donor_id, campaign_id, pool_id, amount) VALUES (?, ?, ?, ?)",
    [donor_id, campaign_id || null, pool_id || null, amount],
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.json({ message: "Donation successful", id: result.insertId });
    }
  );
};

exports.getDonorHistory = (req, res) => {
  const { donor_id } = req.params;
  db.query(
    `SELECT dn.donation_id, dn.amount, dn.donated_at,
            c.title AS campaign
     FROM Donation dn
     LEFT JOIN Campaign c ON dn.campaign_id = c.campaign_id
     WHERE dn.donor_id = ?`,
    [donor_id],
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.json(result);
    }
  );
};

exports.getRecommendations = (req, res) => {
  const { donor_id } = req.params;
  db.query(
    `SELECT c.* FROM Campaign c
     JOIN Campaign_Category cc ON c.campaign_id = cc.campaign_id
     WHERE cc.category_id = (
       SELECT category_id FROM Donation_History
       WHERE donor_id = ?
       ORDER BY total_donated DESC
       LIMIT 1
     ) AND c.status = 'active'`,
    [donor_id],
    (err, result) => {
      if (err) return res.status(500).json(err);
      res.json(result);
    }
  );
};