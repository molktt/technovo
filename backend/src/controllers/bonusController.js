const pool = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');

const getHostBonus = async (req, res) => {
  try {
    const { host_id, sortBy = 'total_bonus', sortOrder = 'DESC', page = 1, limit = 10 } = req.query;
    const conditions = ["u.role = 'HOST'"];
    const values = [];

    if (req.user.role === 'HOST') {
      conditions.push('u.id = ?');
      values.push(req.user.id);
    } else if (host_id && host_id !== 'all') {
      conditions.push('u.id = ?');
      values.push(host_id);
    }

    const where = `WHERE ${conditions.join(' AND ')}`;
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    const allowedSort = ['host_name', 'total_bonus', 'laptop_qty', 'chromebook_qty'];
    const sort = allowedSort.includes(sortBy) ? sortBy : 'total_bonus';
    const offset = (Math.max(parseInt(page, 10), 1) - 1) * parseInt(limit, 10);

    const [rows] = await pool.query(
      `SELECT u.id AS host_id, u.name AS host_name,
              SUM(CASE WHEN c.name = 'Laptop' THEN lsi.quantity ELSE 0 END) AS laptop_qty,
              SUM(CASE WHEN c.name = 'Chromebook' THEN lsi.quantity ELSE 0 END) AS chromebook_qty,
              SUM(lsi.quantity * br.bonus_amount) AS total_bonus
       FROM users u
       LEFT JOIN live_sales ls ON u.id = ls.host_id AND ls.status = 'completed'
       LEFT JOIN live_sale_items lsi ON ls.id = lsi.live_sale_id
       LEFT JOIN products p ON lsi.product_id = p.id
       LEFT JOIN categories c ON p.category_id = c.id
       LEFT JOIN bonus_rules br ON c.id = br.category_id
       ${where}
       GROUP BY u.id, u.name
       ORDER BY ${sort} ${order}
       LIMIT ? OFFSET ?`,
      [...values, parseInt(limit, 10), offset]
    );

    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) AS total FROM users u ${where}`,
      values
    );

    const bonusData = rows.map((row) => ({
      ...row,
      laptop_bonus: Number(row.laptop_qty) * 10000,
      chromebook_bonus: Number(row.chromebook_qty) * 3000,
      total_bonus: Number(row.total_bonus) || 0,
      laptop_qty: Number(row.laptop_qty) || 0,
      chromebook_qty: Number(row.chromebook_qty) || 0,
    }));

    return sendSuccess(res, { items: bonusData, total, page: parseInt(page, 10), limit: parseInt(limit, 10) });
  } catch (error) {
    console.error('Get bonus error:', error);
    return sendError(res, 'Failed to fetch host bonus', 500);
  }
};

module.exports = { getHostBonus };
