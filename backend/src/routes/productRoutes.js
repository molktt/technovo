const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const {
  getProducts, getProductById, createProduct, updateProduct, deleteProduct,
} = require('../controllers/productController');

const router = express.Router();

router.get('/', auth.authenticate, getProducts);
router.get('/:id', auth.authenticate, getProductById);
router.post('/', auth.authenticate, role('LEADER', 'ADMIN'), createProduct);
router.put('/:id', auth.authenticate, role('LEADER', 'ADMIN'), updateProduct);
router.delete('/:id', auth.authenticate, role('LEADER'), deleteProduct);

module.exports = router;
