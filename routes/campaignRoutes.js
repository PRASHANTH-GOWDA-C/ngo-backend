const express = require("express");
const router = express.Router();
const campaignController = require("../controllers/campaignController");
const db = require('../config/db');

router.get("/", campaignController.getAllCampaigns);
router.post("/", campaignController.createCampaign);

module.exports = router;