const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getHostBonus } = require('../controllers/bonusController');

const router = express.Router();

router.get('/', auth.authenticate, role('LEADER', 'HOST'), getHostBonus);

module.exports = router;
