const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const {
  getLiveSchedules, createLiveSchedule, updateLiveSchedule, deleteLiveSchedule,
} = require('../controllers/liveScheduleController');

const router = express.Router();

router.get('/', auth, role('LEADER', 'HOST'), getLiveSchedules);
router.post('/', auth, role('LEADER'), createLiveSchedule);
router.put('/:id', auth, role('LEADER'), updateLiveSchedule);
router.delete('/:id', auth, role('LEADER'), deleteLiveSchedule);

module.exports = router;
