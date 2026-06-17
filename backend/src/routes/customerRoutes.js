const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getCustomers } = require('../controllers/customerController');

const router = express.Router();

router.get('/', auth.authenticate, role('ADMIN', 'LEADER'), getCustomers);

module.exports = router;
