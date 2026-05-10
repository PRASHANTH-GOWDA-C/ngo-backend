const express = require("express");
const router = express.Router();
const donationController = require("../controllers/donationController");

router.post("/", donationController.donate);
router.get("/history/:donor_id", donationController.getDonorHistory);
router.get("/recommend/:donor_id", donationController.getRecommendations);

module.exports = router;

router.get("/", donationController.getAllDonations);