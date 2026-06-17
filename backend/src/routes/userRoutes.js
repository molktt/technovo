const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const { getUsers, createUser, updateUser, deleteUser } = require('../controllers/userController');

const router = express.Router();

router.get('/', auth.authenticate, role('LEADER'), getUsers);
router.post('/', auth.authenticate, role('LEADER'), createUser);
router.put('/:id', auth.authenticate, role('LEADER'), updateUser);
router.delete('/:id', auth.authenticate, role('LEADER'), deleteUser);

module.exports = router;
