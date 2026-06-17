const express = require('express');
const auth = require('../middleware/auth');
const role = require('../middleware/role');
const {
  getProducts, getProductById, createProduct, updateProduct, deleteProduct,
} = require('../controllers/productController');

const router = express.Router();

router.get('/', auth, getProducts);
router.get('/:id', auth, getProductById);
router.post('/', auth, role('LEADER', 'ADMIN'), createProduct);
router.put('/:id', auth, role('LEADER', 'ADMIN'), updateProduct);
router.delete('/:id', auth, role('LEADER'), deleteProduct);

module.exports = router;
