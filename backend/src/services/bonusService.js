const pool = require('../config/db');

const calculateHostBonus = async (hostId = null) => {
  const conditions = ["ls.status = 'completed'"];
  const values = [];

  if (hostId) {
    conditions.push('ls.host_id = ?');
    values.push(hostId);
  }

  const [rows] = await pool.query(
    `SELECT u.id AS host_id, u.name AS host_name,
            SUM(CASE WHEN c.name = 'Laptop' THEN lsi.quantity ELSE 0 END) AS laptop_qty,
            SUM(CASE WHEN c.name = 'Chromebook' THEN lsi.quantity ELSE 0 END) AS chromebook_qty,
            SUM(lsi.quantity * br.bonus_amount) AS total_bonus
     FROM users u
     LEFT JOIN live_sales ls ON u.id = ls.host_id AND ${conditions[0]}
     LEFT JOIN live_sale_items lsi ON ls.id = lsi.live_sale_id
     LEFT JOIN products p ON lsi.product_id = p.id
     LEFT JOIN categories c ON p.category_id = c.id
     LEFT JOIN bonus_rules br ON c.id = br.category_id
     WHERE u.role = 'HOST' ${hostId ? 'AND u.id = ?' : ''}
     GROUP BY u.id, u.name`,
    hostId ? [hostId] : []
  );

  return rows;
};

module.exports = { calculateHostBonus };
