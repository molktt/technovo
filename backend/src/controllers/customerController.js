const pool = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');

const getCustomers = async (req, res) => {
  try {
    const { search = '', sortBy = 'id', sortOrder = 'DESC', page = 1, limit = 10 } = req.query;
    const conditions = [];
    const values = [];

    if (search) {
      conditions.push('(name LIKE ? OR email LIKE ? OR phone LIKE ?)');
      values.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    const allowedSort = ['id', 'name', 'email', 'created_at'];
    const sort = allowedSort.includes(sortBy) ? sortBy : 'id';
    const offset = (Math.max(parseInt(page, 10), 1) - 1) * parseInt(limit, 10);

    const [rows] = await pool.query(
      `SELECT * FROM customers ${where} ORDER BY ${sort} ${order} LIMIT ? OFFSET ?`,
      [...values, parseInt(limit, 10), offset]
    );

    const [[{ total }]] = await pool.query(`SELECT COUNT(*) AS total FROM customers ${where}`, values);
    return sendSuccess(res, { items: rows, total, page: parseInt(page, 10), limit: parseInt(limit, 10) });
  } catch (error) {
    return sendError(res, 'Failed to fetch customers', 500);
  }
};

module.exports = { getCustomers };
