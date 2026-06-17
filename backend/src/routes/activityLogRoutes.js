const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getActivityLogs } = require('../controllers/activityLogController');

const router = express.Router();

router.get('/', auth.authenticate, role('LEADER'), getActivityLogs);

module.exports = router;
