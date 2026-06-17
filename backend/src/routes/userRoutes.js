const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getUsers, createUser, updateUser, deleteUser } = require('../controllers/userController');

const router = express.Router();

router.get('/', auth, role('LEADER'), getUsers);
router.post('/', auth, role('LEADER'), createUser);
router.put('/:id', auth, role('LEADER'), updateUser);
router.delete('/:id', auth, role('LEADER'), deleteUser);

module.exports = router;
