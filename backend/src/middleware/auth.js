const jwt = require('jsonwebtoken');

const authenticate = (req, res, next) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ 
        success: false, 
        message: 'No token provided' 
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ 
      success: false, 
      message: 'Invalid token',
      error: error.message 
    });
  }
};

const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ 
        success: false, 
        message: 'Not authenticated' 
      });
    }

    const userRole = (req.user.role || '').toString().trim().toUpperCase();
    const normalizedRoles = roles.map(r => r.toUpperCase());

    if (!normalizedRoles.includes(userRole)) {
      return res.status(403).json({ 
        success: false, 
        message: 'Not authorized for this action' 
      });
    }

    next();
  };
};

module.exports = { authenticate, authorize };
