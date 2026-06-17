const bcrypt = require('bcryptjs');
const pool = require('../config/db');
const logActivity = require('../utils/activityLogger');
const { sendSuccess, sendError } = require('../utils/response');

const getUsers = async (req, res) => {
  try {
    const { search = '', role, sortBy = 'id', sortOrder = 'DESC', page = 1, limit = 10 } = req.query;
    const conditions = [];
    const values = [];

    if (search) {
      conditions.push('(full_name LIKE ? OR email LIKE ?)');
      values.push(`%${search}%`, `%${search}%`);
    }
    if (role && role !== 'all') {
      conditions.push('role = ?');
      values.push(role);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    const allowedSort = ['id', 'full_name', 'email', 'role', 'created_at'];
    const sort = allowedSort.includes(sortBy) ? sortBy : 'id';
    const offset = (Math.max(parseInt(page, 10), 1) - 1) * parseInt(limit, 10);

    const [rows] = await pool.query(
      `SELECT id, full_name, email, role, is_active, created_at FROM users ${where}
       ORDER BY ${sort} ${order} LIMIT ? OFFSET ?`,
      [...values, parseInt(limit, 10), offset]
    );

    const [[{ total }]] = await pool.query(`SELECT COUNT(*) AS total FROM users ${where}`, values);
    return sendSuccess(res, { items: rows, total, page: parseInt(page, 10), limit: parseInt(limit, 10) });
  } catch (error) {
    return sendError(res, 'Failed to fetch users', 500);
  }
};

const createUser = async (req, res) => {
  try {
    const { full_name, email, password, role } = req.body;
    if (!full_name || !email || !password || !role) {
      return sendError(res, 'All fields are required', 400);
    }

    const hashed = await bcrypt.hash(password, 10);
    const [result] = await pool.query(
      'INSERT INTO users (full_name, email, password, role) VALUES (?, ?, ?, ?)',
      [full_name, email, hashed, role]
    );

    await logActivity(req.user.id, 'CREATE', 'Users', `Created user ${full_name}`);
    return sendSuccess(res, { id: result.insertId }, 'User created successfully', 201);
  } catch (error) {
    if (error.code === 'ER_DUP_ENTRY') return sendError(res, 'Email already exists', 400);
    return sendError(res, 'Failed to create user', 500);
  }
};

const updateUser = async (req, res) => {
  try {
    const { full_name, email, password, role, is_active } = req.body;
    const { id } = req.params;

    const [existing] = await pool.query('SELECT id FROM users WHERE id = ?', [id]);
    if (!existing.length) return sendError(res, 'User not found', 404);

    if (password) {
      const hashed = await bcrypt.hash(password, 10);
      await pool.query(
        'UPDATE users SET full_name=?, email=?, password=?, role=?, is_active=? WHERE id=?',
        [full_name, email, hashed, role, is_active ?? 1, id]
      );
    } else {
      await pool.query(
        'UPDATE users SET full_name=?, email=?, role=?, is_active=? WHERE id=?',
        [full_name, email, role, is_active ?? 1, id]
      );
    }

    await logActivity(req.user.id, 'UPDATE', 'Users', `Updated user ${full_name}`);
    return sendSuccess(res, null, 'User updated successfully');
  } catch (error) {
    return sendError(res, 'Failed to update user', 500);
  }
};

const deleteUser = async (req, res) => {
  try {
    const [existing] = await pool.query('SELECT full_name FROM users WHERE id = ?', [req.params.id]);
    if (!existing.length) return sendError(res, 'User not found', 404);

    await pool.query('DELETE FROM users WHERE id = ?', [req.params.id]);
    await logActivity(req.user.id, 'DELETE', 'Users', `Deleted user ${existing[0].full_name}`);
    return sendSuccess(res, null, 'User deleted successfully');
  } catch (error) {
    return sendError(res, 'Failed to delete user', 500);
  }
};

module.exports = { getUsers, createUser, updateUser, deleteUser };
