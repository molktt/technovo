const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getLiveSales, createLiveSale } = require('../controllers/liveSaleController');

const router = express.Router();

router.get('/', auth.authenticate, role('LEADER', 'HOST'), getLiveSales);
router.post('/', auth.authenticate, role('LEADER', 'HOST'), createLiveSale);

module.exports = router;
