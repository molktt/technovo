const pool = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');

const getActivityLogs = async (req, res) => {
  try {
    const { search = '', module, sortBy = 'created_at', sortOrder = 'DESC', page = 1, limit = 10 } = req.query;
    const conditions = [];
    const values = [];

    if (search) {
      conditions.push('(al.action LIKE ? OR al.module LIKE ? OR al.description LIKE ? OR u.name LIKE ?)');
      values.push(`%${search}%`, `%${search}%`, `%${search}%`, `%${search}%`);
    }
    if (module && module !== 'all') {
      conditions.push('al.module = ?');
      values.push(module);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    const allowedSort = ['id', 'action', 'module', 'created_at'];
    const sort = allowedSort.includes(sortBy) ? sortBy : 'created_at';
    const offset = (Math.max(parseInt(page, 10), 1) - 1) * parseInt(limit, 10);

    const [rows] = await pool.query(
      `SELECT al.*, u.name AS user_name FROM activity_logs al
       LEFT JOIN users u ON al.user_id = u.id
       ${where} ORDER BY al.${sort} ${order} LIMIT ? OFFSET ?`,
      [...values, parseInt(limit, 10), offset]
    );

    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) AS total FROM activity_logs al LEFT JOIN users u ON al.user_id = u.id ${where}`,
      values
    );

    return sendSuccess(res, { items: rows, total, page: parseInt(page, 10), limit: parseInt(limit, 10) });
  } catch (error) {
    return sendError(res, 'Failed to fetch activity logs', 500);
  }
};

module.exports = { getActivityLogs };
