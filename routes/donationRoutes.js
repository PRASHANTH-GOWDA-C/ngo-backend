const express = require("express");
const router = express.Router();
const db = require('../config/db');

// GET /api/donations — returns all donations with donor name, campaign title, NGO name
router.get("/", (req, res) => {
  const sql = `
    SELECT
      dn.donation_id,
      dn.donor_id,
      d.name        AS donor_name,
      dn.campaign_id,
      c.title       AS campaign,
      n.name        AS ngo_name,
      dn.amount,
      dn.donated_at
    FROM Donation dn
    JOIN Donor d    ON dn.donor_id    = d.donor_id
    LEFT JOIN Campaign c ON dn.campaign_id = c.campaign_id
    LEFT JOIN NGO n      ON c.ngo_id       = n.ngo_id
    ORDER BY dn.donated_at DESC
  `;
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

// POST /api/donations — create a new donation
router.post("/", (req, res) => {
  const { donor_id, campaign_id, pool_id, amount } = req.body;
  const sql = `INSERT INTO Donation (donor_id, campaign_id, pool_id, amount) VALUES (?, ?, ?, ?)`;
  db.query(sql, [donor_id, campaign_id || null, pool_id || null, amount], (err, result) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ id: result.insertId, donor_id, campaign_id, amount });
  });
});

module.exports = router;
