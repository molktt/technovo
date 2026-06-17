// controllers/dashboardController.js
const pool = require('../config/db');

// Dashboard Leader
const getDashboardLeader = async (req, res) => {
  try {
    const conn = await pool.getConnection();

    // Summary data
    const [liveSalesData] = await conn.query(
      "SELECT COALESCE(SUM(total_amount), 0) as total FROM live_sales WHERE status='completed'"
    );
    const [marketplaceSalesData] = await conn.query(
      "SELECT COALESCE(SUM(total_amount), 0) as total FROM marketplace_orders WHERE status='delivered'"
    );
    const [ordersData] = await conn.query(
      'SELECT COUNT(*) as total FROM marketplace_orders'
    );

    // Bonus calculation: Laptop=10000, Chromebook=3000
    // Based on live_sale_items joined with products/categories and bonus_rules
    const [bonusData] = await conn.query(
      `SELECT COALESCE(SUM(lsi.quantity * br.bonus_amount), 0) as total
       FROM live_sale_items lsi
       JOIN live_sales ls ON lsi.live_sale_id = ls.id
       JOIN products p ON lsi.product_id = p.id
       JOIN bonus_rules br ON p.category_id = br.category_id
       WHERE ls.status = 'completed'`
    );

    const [liveSold] = await conn.query(
      "SELECT COALESCE(SUM(quantity), 0) as total FROM live_sale_items lsi JOIN live_sales ls ON lsi.live_sale_id = ls.id WHERE ls.status = 'completed'"
    );
    const [marketSold] = await conn.query(
      "SELECT COALESCE(SUM(quantity), 0) as total FROM marketplace_order_items moi JOIN marketplace_orders mo ON moi.order_id = mo.id WHERE mo.status = 'delivered'"
    );
    const totalProductsSold = (liveSold[0]?.total || 0) + (marketSold[0]?.total || 0);

    // Sales trend chart (last 6 months)
    const [salesTrend] = await conn.query(
      `SELECT 
        DATE_FORMAT(m.dt, '%b') as month,
        (SELECT COALESCE(SUM(total_amount), 0) FROM live_sales WHERE status='completed' AND DATE_FORMAT(sale_date, '%Y-%m') = DATE_FORMAT(m.dt, '%Y-%m')) as liveSales,
        (SELECT COALESCE(SUM(total_amount), 0) FROM marketplace_orders WHERE status='delivered' AND DATE_FORMAT(order_date, '%Y-%m') = DATE_FORMAT(m.dt, '%Y-%m')) as marketplaceSales
       FROM (
         SELECT CURDATE() - INTERVAL (n.n) MONTH as dt
         FROM (SELECT 0 as n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) n
       ) m
       ORDER BY m.dt ASC`
    );

    // Marketplace comparison chart
    const [marketplaceComparison] = await conn.query(
      `SELECT p.name as platform, COALESCE(SUM(mo.total_amount), 0) as total
       FROM platforms p
       LEFT JOIN marketplace_orders mo ON p.id = mo.platform_id AND mo.status = 'delivered'
       GROUP BY p.id, p.name`
    );

    // Stock summary
    const [stockSummary] = await conn.query(
      `SELECT c.name as category, COALESCE(SUM(p.stock), 0) as stock
       FROM categories c
       LEFT JOIN products p ON c.id = p.category_id
       GROUP BY c.id, c.name`
    );

    // Recent activities
    const [recentActivities] = await conn.query(
      `SELECT al.id, u.name as user_name, al.action, al.module, al.created_at
       FROM activity_logs al
       JOIN users u ON al.user_id = u.id
       ORDER BY al.created_at DESC
       LIMIT 10`
    );

    // Recent orders
    const [recentOrders] = await conn.query(
      `SELECT mo.id, mo.order_number, c.name as customer_name, p.name as platform_name, mo.total_amount, mo.status
       FROM marketplace_orders mo
       LEFT JOIN customers c ON mo.customer_id = c.id
       LEFT JOIN platforms p ON mo.platform_id = p.id
       ORDER BY mo.order_date DESC
       LIMIT 10`
    );

    conn.release();

    return res.status(200).json({
      success: true,
      data: {
        summary: {
          totalLiveSales: liveSalesData[0]?.total || 0,
          totalMarketplaceSales: marketplaceSalesData[0]?.total || 0,
          totalOrders: ordersData[0]?.total || 0,
          totalBonusHost: bonusData[0]?.total || 0,
          totalProductsSold: totalProductsSold
        },
        charts: {
          salesTrend: salesTrend || [],
          marketplaceComparison: marketplaceComparison || [],
          stockSummary: stockSummary || []
        },
        recentActivities: recentActivities || [],
        recentOrders: recentOrders || []
      }
    });
  } catch (error) {
    console.error('Dashboard leader error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// Dashboard Admin
const getDashboardAdmin = async (req, res) => {
  try {
    const conn = await pool.getConnection();

    // Summary data
    const [marketplaceSalesData] = await conn.query(
      "SELECT COALESCE(SUM(total_amount), 0) as total FROM marketplace_orders WHERE status='delivered'"
    );
    const [productsCount] = await conn.query(
      'SELECT COUNT(*) as total FROM products'
    );
    const [returnsCount] = await conn.query(
      'SELECT COUNT(*) as total FROM returns'
    );
    const [customersCount] = await conn.query(
      'SELECT COUNT(*) as total FROM customers'
    );

    // Sales trend chart (monthly)
    const [salesTrend] = await conn.query(
      `SELECT 
        DATE_FORMAT(m.dt, '%b') as month,
        (SELECT COALESCE(SUM(total_amount), 0) FROM marketplace_orders WHERE status='delivered' AND DATE_FORMAT(order_date, '%Y-%m') = DATE_FORMAT(m.dt, '%Y-%m')) as marketplaceSales
       FROM (
         SELECT CURDATE() - INTERVAL (n.n) MONTH as dt
         FROM (SELECT 0 as n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) n
       ) m
       ORDER BY m.dt ASC`
    );

    // Marketplace comparison chart
    const [marketplaceComparison] = await conn.query(
      `SELECT p.name as platform, COALESCE(SUM(mo.total_amount), 0) as total
       FROM platforms p
       LEFT JOIN marketplace_orders mo ON p.id = mo.platform_id AND mo.status = 'delivered'
       GROUP BY p.id, p.name`
    );

    // Stock summary
    const [stockSummary] = await conn.query(
      `SELECT c.name as category, COALESCE(SUM(p.stock), 0) as stock
       FROM categories c
       LEFT JOIN products p ON c.id = p.category_id
       GROUP BY c.id, c.name`
    );

    // Recent activities
    const [recentActivities] = await conn.query(
      `SELECT al.id, u.name as user_name, al.action, al.module, al.created_at
       FROM activity_logs al
       JOIN users u ON al.user_id = u.id
       ORDER BY al.created_at DESC
       LIMIT 10`
    );

    // Recent orders
    const [recentOrders] = await conn.query(
      `SELECT mo.id, mo.order_number, c.name as customer_name, p.name as platform_name, mo.total_amount, mo.status
       FROM marketplace_orders mo
       LEFT JOIN customers c ON mo.customer_id = c.id
       LEFT JOIN platforms p ON mo.platform_id = p.id
       ORDER BY mo.order_date DESC
       LIMIT 10`
    );

    conn.release();

    return res.status(200).json({
      success: true,
      data: {
        summary: {
          totalLiveSales: 0,
          totalMarketplaceSales: marketplaceSalesData[0]?.total || 0,
          totalOrders: productsCount[0]?.total || 0,
          totalBonusHost: returnsCount[0]?.total || 0,
          totalProductsSold: customersCount[0]?.total || 0
        },
        charts: {
          salesTrend: salesTrend || [],
          marketplaceComparison: marketplaceComparison || [],
          stockSummary: stockSummary || []
        },
        recentActivities: recentActivities || [],
        recentOrders: recentOrders || []
      }
    });
  } catch (error) {
    console.error('Dashboard admin error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

// Dashboard Host
const getDashboardHost = async (req, res) => {
  try {
    const conn = await pool.getConnection();
    const hostId = req.user.id;

    // Summary data
    const [liveSalesData] = await conn.query(
      `SELECT COALESCE(SUM(ls.total_amount), 0) as total
       FROM live_sales ls
       WHERE ls.host_id = ? AND ls.status = 'completed'`,
      [hostId]
    );
    const [schedulesData] = await conn.query(
      'SELECT COUNT(*) as total FROM live_schedules WHERE host_id = ?',
      [hostId]
    );

    // Bonus for this host
    const [bonusData] = await conn.query(
      `SELECT COALESCE(SUM(lsi.quantity * br.bonus_amount), 0) as total
       FROM live_sale_items lsi
       JOIN live_sales ls ON lsi.live_sale_id = ls.id
       JOIN products p ON lsi.product_id = p.id
       JOIN bonus_rules br ON p.category_id = br.category_id
       WHERE ls.host_id = ? AND ls.status = 'completed'`,
      [hostId]
    );

    const [productsSold] = await conn.query(
      `SELECT COALESCE(SUM(lsi.quantity), 0) as total
       FROM live_sale_items lsi
       JOIN live_sales ls ON lsi.live_sale_id = ls.id
       WHERE ls.host_id = ? AND ls.status = 'completed'`,
      [hostId]
    );

    // Sales trend chart (monthly)
    const [salesTrend] = await conn.query(
      `SELECT 
        DATE_FORMAT(m.dt, '%b') as month,
        (SELECT COALESCE(SUM(total_amount), 0) FROM live_sales WHERE host_id = ? AND status='completed' AND DATE_FORMAT(sale_date, '%Y-%m') = DATE_FORMAT(m.dt, '%Y-%m')) as liveSales
       FROM (
         SELECT CURDATE() - INTERVAL (n.n) MONTH as dt
         FROM (SELECT 0 as n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) n
       ) m
       ORDER BY m.dt ASC`,
      [hostId]
    );

    // Platform comparison
    const [marketplaceComparison] = await conn.query(
      `SELECT p.name as platform, COALESCE(SUM(ls.total_amount), 0) as total
       FROM platforms p
       JOIN live_schedules lsch ON p.id = lsch.platform_id
       JOIN live_sales ls ON lsch.id = ls.schedule_id
       WHERE ls.host_id = ? AND ls.status = 'completed'
       GROUP BY p.id, p.name`,
      [hostId]
    );

    // Stock summary (Total Completed vs Scheduled for host)
    const [stockSummary] = await conn.query(
      `SELECT status as category, COUNT(*) as stock
       FROM live_schedules
       WHERE host_id = ?
       GROUP BY status`,
      [hostId]
    );

    // Recent activities
    const [recentActivities] = await conn.query(
      `SELECT al.id, u.name as user_name, al.action, al.module, al.created_at
       FROM activity_logs al
       JOIN users u ON al.user_id = u.id
       WHERE u.id = ?
       ORDER BY al.created_at DESC
       LIMIT 10`,
      [hostId]
    );

    // Recent live sales
    const [recentOrders] = await conn.query(
      `SELECT ls.id, ls.sale_date as order_date, u.name as customer_name, p.name as platform_name, ls.total_amount
       FROM live_sales ls
       JOIN users u ON ls.host_id = u.id
       JOIN live_schedules lsch ON ls.schedule_id = lsch.id
       JOIN platforms p ON lsch.platform_id = p.id
       WHERE ls.host_id = ?
       ORDER BY ls.sale_date DESC
       LIMIT 10`,
      [hostId]
    );

    conn.release();

    return res.status(200).json({
      success: true,
      data: {
        summary: {
          totalLiveSales: liveSalesData[0]?.total || 0,
          totalMarketplaceSales: 0,
          totalOrders: schedulesData[0]?.total || 0,
          totalBonusHost: bonusData[0]?.total || 0,
          totalProductsSold: productsSold[0]?.total || 0
        },
        charts: {
          salesTrend: salesTrend || [],
          marketplaceComparison: marketplaceComparison || [],
          stockSummary: stockSummary || []
        },
        recentActivities: recentActivities || [],
        recentOrders: recentOrders || []
      }
    });
  } catch (error) {
    console.error('Dashboard host error:', error);
    return res.status(500).json({
      success: false,
      message: 'Server error',
      error: error.message
    });
  }
};

module.exports = {
  getDashboardLeader,
  getDashboardAdmin,
  getDashboardHost
};
