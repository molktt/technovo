const bcrypt = require('bcryptjs');
const pool = require('../config/db');
const logActivity = require('../utils/activityLogger');
const { sendSuccess, sendError } = require('../utils/response');

const getProducts = async (req, res) => {
  try {
    const { search = '', category_id, brand, sortBy = 'id', sortOrder = 'DESC', page = 1, limit = 10 } = req.query;
    const conditions = [];
    const values = [];

    if (search) {
      conditions.push('(p.name LIKE ? OR p.sku LIKE ? OR p.brand LIKE ?)');
      values.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }
    if (category_id && category_id !== 'all') {
      conditions.push('p.category_id = ?');
      values.push(category_id);
    }
    if (brand && brand !== 'all') {
      conditions.push('p.brand = ?');
      values.push(brand);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    const allowedSort = ['id', 'name', 'brand', 'price', 'stock', 'created_at'];
    const sort = allowedSort.includes(sortBy) ? sortBy : 'id';
    const offset = (Math.max(parseInt(page, 10), 1) - 1) * parseInt(limit, 10);

    const [rows] = await pool.query(
      `SELECT p.*, c.name AS category_name FROM products p
       LEFT JOIN categories c ON p.category_id = c.id
       ${where} ORDER BY p.${sort} ${order} LIMIT ? OFFSET ?`,
      [...values, parseInt(limit, 10), offset]
    );

    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) AS total FROM products p ${where}`,
      values
    );

    return sendSuccess(res, { items: rows, total, page: parseInt(page, 10), limit: parseInt(limit, 10) });
  } catch (error) {
    console.error('Get products error:', error);
    return sendError(res, 'Failed to fetch products', 500);
  }
};

const getProductById = async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT p.*, c.name AS category_name FROM products p
       LEFT JOIN categories c ON p.category_id = c.id WHERE p.id = ?`,
      [req.params.id]
    );
    if (!rows.length) return sendError(res, 'Product not found', 404);
    return sendSuccess(res, rows[0]);
  } catch (error) {
    return sendError(res, 'Failed to fetch product', 500);
  }
};

const createProduct = async (req, res) => {
  try {
    const { name, sku, brand, category_id, price, stock } = req.body;
    if (!name || !sku || !brand || !category_id || price === undefined) {
      return sendError(res, 'All fields are required', 400);
    }

    const [result] = await pool.query(
      'INSERT INTO products (name, sku, brand, category_id, price, stock) VALUES (?, ?, ?, ?, ?, ?)',
      [name, sku, brand, category_id, price, stock || 0]
    );

    await pool.query(
      'INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [result.insertId, 'IN', stock || 0, 'product', result.insertId, 'Initial stock', req.user.id]
    );

    await logActivity(req.user.id, 'CREATE', 'Products', `Created product ${name}`);
    return sendSuccess(res, { id: result.insertId }, 'Product created successfully', 201);
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') return sendError(res, 'SKU already exists', 400);
    return sendError(res, 'Failed to create product', 500);
  }
};

const updateProduct = async (req, res) => {
  try {
    const { name, sku, brand, category_id, price, stock } = req.body;
    const { id } = req.params;

    const [existing] = await pool.query('SELECT stock FROM products WHERE id = ?', [id]);
    if (!existing.length) return sendError(res, 'Product not found', 404);

    const oldStock = existing[0].stock;
    const newStock = stock !== undefined ? stock : oldStock;
    const stockDiff = newStock - oldStock;

    await pool.query(
      'UPDATE products SET name=?, sku=?, brand=?, category_id=?, price=?, stock=? WHERE id=?',
      [name, sku, brand, category_id, price, newStock, id]
    );

    if (stockDiff !== 0) {
      await pool.query(
        'INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by) VALUES (?, ?, ?, ?, ?, ?, ?)',
        [id, stockDiff > 0 ? 'IN' : 'OUT', Math.abs(stockDiff), 'adjustment', id, 'Stock adjustment', req.user.id]
      );
    }

    await logActivity(req.user.id, 'UPDATE', 'Products', `Updated product ${name}`);
    return sendSuccess(res, null, 'Product updated successfully');
  } catch (error) {
    return sendError(res, 'Failed to update product', 500);
  }
};

const deleteProduct = async (req, res) => {
  try {
    const [existing] = await pool.query('SELECT name FROM products WHERE id = ?', [req.params.id]);
    if (!existing.length) return sendError(res, 'Product not found', 404);

    await pool.query('DELETE FROM products WHERE id = ?', [req.params.id]);
    await logActivity(req.user.id, 'DELETE', 'Products', `Deleted product ${existing[0].name}`);
    return sendSuccess(res, null, 'Product deleted successfully');
  } catch (error) {
    return sendError(res, 'Failed to delete product', 500);
  }
};

module.exports = { getProducts, getProductById, createProduct, updateProduct, deleteProduct };
