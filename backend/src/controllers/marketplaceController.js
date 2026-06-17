const pool = require('../config/db');
const logActivity = require('../utils/activityLogger');
const { sendSuccess, sendError } = require('../utils/response');

const getOrders = async (req, res) => {
  try {
    const { search = '', platform_id, status, sortBy = 'order_date', sortOrder = 'DESC', page = 1, limit = 10 } = req.query;
    const conditions = [];
    const values = [];

    if (search) {
      conditions.push('(mo.order_number LIKE ? OR c.name LIKE ? OR c.email LIKE ?)');
      values.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }
    if (platform_id && platform_id !== 'all') {
      conditions.push('mo.platform_id = ?');
      values.push(platform_id);
    }
    if (status && status !== 'all') {
      conditions.push('mo.status = ?');
      values.push(status);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    const allowedSort = ['id', 'order_number', 'order_date', 'total_amount', 'status'];
    const sort = allowedSort.includes(sortBy) ? sortBy : 'order_date';
    const offset = (Math.max(parseInt(page, 10), 1) - 1) * parseInt(limit, 10);

    const [rows] = await pool.query(
      `SELECT mo.*, c.name AS customer_name, c.email AS customer_email, pl.name AS platform_name
       FROM marketplace_orders mo
       LEFT JOIN customers c ON mo.customer_id = c.id
       LEFT JOIN platforms pl ON mo.platform_id = pl.id
       ${where} ORDER BY mo.${sort} ${order} LIMIT ? OFFSET ?`,
      [...values, parseInt(limit, 10), offset]
    );

    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) AS total FROM marketplace_orders mo
       LEFT JOIN customers c ON mo.customer_id = c.id ${where}`,
      values
    );

    return sendSuccess(res, { items: rows, total, page: parseInt(page, 10), limit: parseInt(limit, 10) });
  } catch (error) {
    console.error('Get orders error:', error);
    return sendError(res, 'Failed to fetch orders', 500);
  }
};

const createOrder = async (req, res) => {
  const connection = await pool.getConnection();
  try {
    const { customer_id, platform_id, order_date, status, items } = req.body;

    if (!customer_id || !platform_id || !order_date || !items || !items.length) {
      return sendError(res, 'Customer, platform, date and items are required', 400);
    }

    await connection.beginTransaction();

    const orderNumber = `ORD-${Date.now()}-${Math.floor(Math.random() * 1000)}`;
    let totalAmount = 0;

    items.forEach((item) => {
      totalAmount += item.quantity * item.unit_price;
    });

    const [orderResult] = await connection.query(
      `INSERT INTO marketplace_orders (order_number, customer_id, platform_id, order_date, status, total_amount, created_by)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [orderNumber, customer_id, platform_id, order_date, status || 'pending', totalAmount, req.user.id]
    );

    const orderId = orderResult.insertId;

    for (const item of items) {
      const subtotal = item.quantity * item.unit_price;
      await connection.query(
        `INSERT INTO marketplace_order_items (order_id, product_id, quantity, unit_price, subtotal)
         VALUES (?, ?, ?, ?, ?)`,
        [orderId, item.product_id, item.quantity, item.unit_price, subtotal]
      );

      if (status === 'delivered' || status === 'shipped') {
        await connection.query('UPDATE products SET stock = stock - ? WHERE id = ?', [item.quantity, item.product_id]);
        await connection.query(
          `INSERT INTO stock_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by)
           VALUES (?, 'OUT', ?, 'marketplace_order', ?, 'Marketplace order stock out', ?)`,
          [item.product_id, item.quantity, orderId, req.user.id]
        );
      }
    }

    await connection.commit();
    await logActivity(req.user.id, 'CREATE', 'Marketplace', `Created order ${orderNumber}`);
    return sendSuccess(res, { id: orderId, order_number: orderNumber }, 'Order created successfully', 201);
  } catch (error) {
    await connection.rollback();
    console.error('Create order error:', error);
    return sendError(res, 'Failed to create order', 500);
  } finally {
    connection.release();
  }
};

module.exports = { getOrders, createOrder };
