const pool = require('../config/db');
const logActivity = require('../utils/activityLogger');
const { sendSuccess, sendError } = require('../utils/response');

const getLiveSales = async (req, res) => {
  try {
    const { search = '', host_id, status, sortBy = 'sale_date', sortOrder = 'DESC', page = 1, limit = 10 } = req.query;
    const conditions = [];
    const values = [];

    if (req.user.role === 'HOST') {
      conditions.push('ls.host_id = ?');
      values.push(req.user.id);
    } else if (host_id && host_id !== 'all') {
      conditions.push('ls.host_id = ?');
      values.push(host_id);
    }

    if (search) {
      conditions.push('(u.full_name LIKE ? OR pl.name LIKE ?)');
      values.push(`%${search}%`, `%${search}%`);
    }
    if (status && status !== 'all') {
      conditions.push('ls.status = ?');
      values.push(status);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    const allowedSort = ['id', 'sale_date', 'total_amount', 'total_items', 'status'];
    const sort = allowedSort.includes(sortBy) ? sortBy : 'sale_date';
    const offset = (Math.max(parseInt(page, 10), 1) - 1) * parseInt(limit, 10);

    const [rows] = await pool.query(
      `SELECT ls.*, u.full_name AS host_name, pl.name AS platform_name, lsc.title AS schedule_title
       FROM live_sales ls
       LEFT JOIN users u ON ls.host_id = u.id
       LEFT JOIN live_schedules lsc ON ls.schedule_id = lsc.id
       LEFT JOIN platforms pl ON lsc.platform_id = pl.id
       ${where} ORDER BY ls.${sort} ${order} LIMIT ? OFFSET ?`,
      [...values, parseInt(limit, 10), offset]
    );

    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) AS total FROM live_sales ls
       LEFT JOIN users u ON ls.host_id = u.id ${where}`,
      values
    );

    return sendSuccess(res, { items: rows, total, page: parseInt(page, 10), limit: parseInt(limit, 10) });
  } catch (error) {
    console.error('Get live sales error:', error);
    return sendError(res, 'Failed to fetch live sales', 500);
  }
};

const createLiveSale = async (req, res) => {
  const connection = await pool.getConnection();
  try {
    const { schedule_id, host_id, sale_date, items, status } = req.body;

    if (!schedule_id || !host_id || !sale_date || !items || !items.length) {
      return sendError(res, 'Schedule, host, date and items are required', 400);
    }

    await connection.beginTransaction();

    let totalAmount = 0;
    let totalItems = 0;

    items.forEach((item) => {
      const subtotal = item.quantity * item.unit_price;
      totalAmount += subtotal;
      totalItems += item.quantity;
    });

    const [saleResult] = await connection.query(
      `INSERT INTO live_sales (schedule_id, host_id, sale_date, total_amount, total_items, status)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [schedule_id, host_id, sale_date, totalAmount, totalItems, status || 'completed']
    );

    const saleId = saleResult.insertId;

    for (const item of items) {
      const subtotal = item.quantity * item.unit_price;
      await connection.query(
        `INSERT INTO live_sale_items (live_sale_id, product_id, quantity, unit_price, subtotal)
         VALUES (?, ?, ?, ?, ?)`,
        [saleId, item.product_id, item.quantity, item.unit_price, subtotal]
      );

      await connection.query('UPDATE products SET stock = stock - ? WHERE id = ?', [item.quantity, item.product_id]);

      await connection.query(
        `INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by)
         VALUES (?, 'OUT', ?, 'live_sale', ?, 'Live sale stock out', ?)`,
        [item.product_id, item.quantity, saleId, req.user.id]
      );
    }

    await connection.query(`UPDATE live_schedules SET status = 'completed' WHERE id = ?`, [schedule_id]);
    await connection.commit();

    await logActivity(req.user.id, 'CREATE', 'Live Sales', `Created live sale #${saleId}`);
    return sendSuccess(res, { id: saleId }, 'Live sale created successfully', 201);
  } catch (error) {
    await connection.rollback();
    console.error('Create live sale error:', error);
    return sendError(res, 'Failed to create live sale', 500);
  } finally {
    connection.release();
  }
};

module.exports = { getLiveSales, createLiveSale };
