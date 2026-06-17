const express = require('express');
const auth = require('../middleware/auth');
const { getMasterData } = require('../controllers/masterController');

const router = express.Router();

router.get('/', auth, getMasterData);

module.exports = router;
