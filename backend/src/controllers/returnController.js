const pool = require('../config/db');
const logActivity = require('../utils/activityLogger');
const { sendSuccess, sendError } = require('../utils/response');

const getReturns = async (req, res) => {
  try {
    const { search = '', status, sortBy = 'return_date', sortOrder = 'DESC', page = 1, limit = 10 } = req.query;
    const conditions = [];
    const values = [];

    if (search) {
      conditions.push('(mo.order_number LIKE ? OR p.name LIKE ? OR r.reason LIKE ?)');
      values.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }
    if (status && status !== 'all') {
      conditions.push('r.status = ?');
      values.push(status);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    const allowedSort = ['id', 'return_date', 'status', 'quantity'];
    const sort = allowedSort.includes(sortBy) ? sortBy : 'return_date';
    const offset = (Math.max(parseInt(page, 10), 1) - 1) * parseInt(limit, 10);

    const [rows] = await pool.query(
      `SELECT r.*, mo.order_number, p.name AS product_name, c.name AS customer_name
       FROM returns r
       LEFT JOIN marketplace_orders mo ON r.order_id = mo.id
       LEFT JOIN products p ON r.product_id = p.id
       LEFT JOIN customers c ON mo.customer_id = c.id
       ${where} ORDER BY r.${sort} ${order} LIMIT ? OFFSET ?`,
      [...values, parseInt(limit, 10), offset]
    );

    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) AS total FROM returns r
       LEFT JOIN marketplace_orders mo ON r.order_id = mo.id
       LEFT JOIN products p ON r.product_id = p.id ${where}`,
      values
    );

    return sendSuccess(res, { items: rows, total, page: parseInt(page, 10), limit: parseInt(limit, 10) });
  } catch (error) {
    return sendError(res, 'Failed to fetch returns', 500);
  }
};

const createReturn = async (req, res) => {
  const connection = await pool.getConnection();
  try {
    const { order_id, product_id, quantity, reason, return_date, status } = req.body;

    if (!order_id || !product_id || !quantity || !return_date) {
      return sendError(res, 'Required fields missing', 400);
    }

    await connection.beginTransaction();

    const [result] = await connection.query(
      `INSERT INTO returns (order_id, product_id, quantity, reason, return_date, status)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [order_id, product_id, quantity, reason || '', return_date, status || 'pending']
    );

    await connection.query('UPDATE products SET stock = stock + ? WHERE id = ?', [quantity, product_id]);

    await connection.query(
      `INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by)
       VALUES (?, 'IN', ?, 'return', ?, 'Return stock in', ?)`,
      [product_id, quantity, result.insertId, req.user.id]
    );

    await connection.commit();
    await logActivity(req.user.id, 'CREATE', 'Returns', `Created return for order #${order_id}`);
    return sendSuccess(res, { id: result.insertId }, 'Return created successfully', 201);
  } catch (error) {
    await connection.rollback();
    return sendError(res, 'Failed to create return', 500);
  } finally {
    connection.release();
  }
};

module.exports = { getReturns, createReturn };
