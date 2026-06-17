const pool = require('../config/db');
const { sendSuccess, sendError } = require('../utils/response');

const getMasterData = async (req, res) => {
  try {
    const [platforms] = await pool.query('SELECT * FROM platforms ORDER BY name');
    const [categories] = await pool.query('SELECT * FROM categories ORDER BY name');
    const [hosts] = await pool.query("SELECT id, full_name FROM users WHERE role = 'HOST' AND is_active = 1 ORDER BY full_name");
    const [products] = await pool.query('SELECT id, name, sku, price, stock, category_id, brand FROM products ORDER BY name');
    const [customers] = await pool.query('SELECT id, name, email FROM customers ORDER BY name');
    const [orders] = await pool.query("SELECT id, order_number FROM marketplace_orders WHERE status = 'delivered' ORDER BY order_date DESC LIMIT 500");

    return sendSuccess(res, { platforms, categories, hosts, products, customers, orders });
  } catch (error) {
    return sendError(res, 'Failed to fetch master data', 500);
  }
};

module.exports = { getMasterData };
