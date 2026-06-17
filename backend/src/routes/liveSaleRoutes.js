const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getLiveSales, createLiveSale } = require('../controllers/liveSaleController');

const router = express.Router();

router.get('/', auth, role('LEADER', 'HOST'), getLiveSales);
router.post('/', auth, role('LEADER', 'HOST'), createLiveSale);

module.exports = router;
