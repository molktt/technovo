const pool = require('../config/db');

const logActivity = async (userId, action, module, description) => {
  try {
    await pool.query(
      'INSERT INTO activity_logs (user_id, action, module, description) VALUES (?, ?, ?, ?)',
      [userId, action, module, description]
    );
  } catch (error) {
    console.error('Activity log error:', error.message);
  }
};

module.exports = logActivity;
