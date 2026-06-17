const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getReturns, createReturn } = require('../controllers/returnController');

const router = express.Router();

router.get('/', auth.authenticate, role('LEADER', 'ADMIN'), getReturns);
router.post('/', auth.authenticate, role('LEADER', 'ADMIN'), createReturn);

module.exports = router;
