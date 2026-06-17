const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getLeaderDashboard, getAdminDashboard, getHostDashboard } = require('../controllers/dashboardController');

const router = express.Router();

router.get('/leader', auth, role('LEADER'), getLeaderDashboard);
router.get('/admin', auth, role('ADMIN', 'LEADER'), getAdminDashboard);
router.get('/host', auth, role('HOST'), getHostDashboard);

module.exports = router;
