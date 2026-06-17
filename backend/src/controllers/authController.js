// controllers/authController.js
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const pool = require('../config/db');

const login = async (req, res) => {
  let conn;

  try {
    const { email, password } = req.body;

    console.log('================================');
    console.log('LOGIN ATTEMPT');
    console.log('Email:', email);
    console.log('Password:', password);
    console.log('================================');

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Email and password required'
      });
    }

    conn = await pool.getConnection();

    const [users] = await conn.query(
      'SELECT * FROM users WHERE email = ? LIMIT 1',
      [email]
    );

    console.log('Users Found:', users.length);

    if (users.length === 0) {
      return res.status(401).json({
        success: false,
        message: 'Email not found'
      });
    }

    const user = users[0];

    console.log('DB Email:', user.email);
    console.log('Role:', user.role);
    console.log('Is Active:', user.is_active);
    console.log('Password Hash:', user.password);

    // Optional: cek user aktif
    if (user.is_active === 0) {
      return res.status(403).json({
        success: false,
        message: 'Account is inactive'
      });
    }

    const isPasswordValid = await bcrypt.compare(
      password,
      user.password
    );

    console.log('Password Valid:', isPasswordValid);

    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Wrong password'
      });
    }

    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        role: user.role,
        full_name: user.full_name
      },
      process.env.JWT_SECRET,
      {
        expiresIn: process.env.JWT_EXPIRE || '7d'
      }
    );

    console.log('LOGIN SUCCESS');

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        full_name: user.full_name,
        phone_number: user.phone_number
      }
    });

  } catch (error) {
    console.error('LOGIN ERROR');
    console.error(error);

    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });

  } finally {
    if (conn) conn.release();
  }
};

const getCurrentUser = async (req, res) => {
  let conn;

  try {
    conn = await pool.getConnection();

    const [users] = await conn.query(
      `SELECT
        id,
        email,
        role,
        full_name,
        phone_number,
        is_active
      FROM users
      WHERE id = ?`,
      [req.user.id]
    );

    if (users.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    return res.status(200).json({
      success: true,
      user: users[0]
    });

  } catch (error) {
    console.error(error);

    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });

  } finally {
    if (conn) conn.release();
  }
};

module.exports = {
  login,
  getCurrentUser
};