const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getOrders, createOrder } = require('../controllers/marketplaceController');

const router = express.Router();

router.get('/', auth, role('LEADER', 'ADMIN'), getOrders);
router.post('/', auth, role('LEADER', 'ADMIN'), createOrder);

module.exports = router;
