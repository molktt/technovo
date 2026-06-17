const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getStockMovements } = require('../controllers/stockMovementController');

const router = express.Router();

router.get('/', auth, role('LEADER', 'ADMIN'), getStockMovements);

module.exports = router;
