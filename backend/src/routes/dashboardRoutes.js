const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getDashboardLeader, getDashboardAdmin, getDashboardHost } = require('../controllers/dashboardController');

const router = express.Router();

router.get('/leader', auth.authenticate, role('LEADER'), getDashboardLeader);
router.get('/admin', auth.authenticate, role('ADMIN', 'LEADER'), getDashboardAdmin);
router.get('/host', auth.authenticate, role('HOST'), getDashboardHost);

module.exports = router;
