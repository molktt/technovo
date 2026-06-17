const pool = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');

const getStockMovements = async (req, res) => {
  try {
    const { search = '', movement_type, sortBy = 'created_at', sortOrder = 'DESC', page = 1, limit = 10 } = req.query;
    const conditions = [];
    const values = [];

    if (search) {
      conditions.push('(p.name LIKE ? OR p.sku LIKE ? OR sm.notes LIKE ?)');
      values.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }
    if (movement_type && movement_type !== 'all') {
      conditions.push('sm.movement_type = ?');
      values.push(movement_type);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    const allowedSort = ['id', 'quantity', 'movement_type', 'created_at'];
    const sort = allowedSort.includes(sortBy) ? sortBy : 'created_at';
    const offset = (Math.max(parseInt(page, 10), 1) - 1) * parseInt(limit, 10);

    const [rows] = await pool.query(
      `SELECT sm.*, p.name AS product_name, p.sku, u.full_name AS created_by_name
       FROM stock_movements sm
       LEFT JOIN products p ON sm.product_id = p.id
       LEFT JOIN users u ON sm.created_by = u.id
       ${where} ORDER BY sm.${sort} ${order} LIMIT ? OFFSET ?`,
      [...values, parseInt(limit, 10), offset]
    );

    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) AS total FROM stock_movements sm
       LEFT JOIN products p ON sm.product_id = p.id ${where}`,
      values
    );

    return sendSuccess(res, { items: rows, total, page: parseInt(page, 10), limit: parseInt(limit, 10) });
  } catch (error) {
    return sendError(res, 'Failed to fetch stock movements', 500);
  }
};

module.exports = { getStockMovements };
