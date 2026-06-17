// controllers/dashboardController.js
const pool = require('../config/db');

// Dashboard Leader
const getDashboardLeader = async (req, res) => {
  try {
    const conn = await pool.getConnection();

    // Summary data
    const [liveSalesData] = await conn.query(
      'SELECT COALESCE(SUM(total_revenue), 0) as total FROM live_sales'
    );
    const [marketplaceSalesData] = await conn.query(
      'SELECT COALESCE(SUM(total_amount), 0) as total FROM marketplace_orders'
    );
    const [ordersData] = await conn.query(
      'SELECT COUNT(*) as total FROM marketplace_orders'
    );
    const [bonusData] = await conn.query(
      'SELECT COALESCE(SUM(bonus_amount), 0) as total FROM bonuses'
    );
    const [productsSoldData] = await conn.query(
      'SELECT COALESCE(COUNT(*), 0) as total FROM marketplace_orders'
    );

    // Sales trend chart (monthly)
    const [salesTrend] = await conn.query(
      `SELECT 
        DATE_FORMAT(CURDATE() - INTERVAL DAY(CURDATE())-1 DAY + INTERVAL (n-1) MONTH, '%b') as month,
        COALESCE(SUM(CASE WHEN YEAR(ls.schedule_date) = YEAR(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) AND MONTH(ls.schedule_date) = MONTH(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) THEN lsa.total_revenue ELSE 0 END), 0) as liveSales,
        COALESCE(SUM(CASE WHEN YEAR(mo.order_date) = YEAR(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) AND MONTH(mo.order_date) = MONTH(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) THEN mo.total_amount ELSE 0 END), 0) as marketplaceSales
      FROM (
        SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
      ) nums
      LEFT JOIN live_schedules ls ON YEAR(ls.schedule_date) = YEAR(DATE_SUB(NOW(), INTERVAL (6-n) MONTH)) AND MONTH(ls.schedule_date) = MONTH(DATE_SUB(NOW(), INTERVAL (6-n) MONTH))
      LEFT JOIN live_sales lsa ON ls.id = lsa.live_schedule_id
      LEFT JOIN marketplace_orders mo ON YEAR(mo.order_date) = YEAR(DATE_SUB(NOW(), INTERVAL (6-n) MONTH)) AND MONTH(mo.order_date) = MONTH(DATE_SUB(NOW(), INTERVAL (6-n) MONTH))
      GROUP BY n
      ORDER BY n`
    );

    // Marketplace comparison chart
    const [marketplaceComparison] = await conn.query(
      `SELECT p.name as platform, COALESCE(SUM(mo.total_amount), 0) as total
       FROM platforms p
       LEFT JOIN marketplace_orders mo ON p.id = mo.platform_id
       GROUP BY p.id, p.name`
    );

    // Stock summary
    const [stockSummary] = await conn.query(
      `SELECT category_name as category, COALESCE(SUM(stock_quantity), 0) as stock
       FROM product_categories pc
       LEFT JOIN products p ON pc.id = p.category_id
       GROUP BY pc.id, pc.category_name`
    );

    // Recent activities
    const [recentActivities] = await conn.query(
      `SELECT al.id, u.full_name as user_name, al.action, al.module, al.created_at
       FROM activity_logs al
       JOIN users u ON al.user_id = u.id
       ORDER BY al.created_at DESC
       LIMIT 10`
    );

    // Recent orders
    const [recentOrders] = await conn.query(
      `SELECT mo.id, mo.order_number, c.name as customer_name, p.name as platform_name, mo.total_amount
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
          totalProductsSold: productsSoldData[0]?.total || 0
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
    const [productsSalesData] = await conn.query(
      'SELECT COALESCE(SUM(mo.total_amount), 0) as total FROM marketplace_orders mo'
    );
    const [productsData] = await conn.query(
      'SELECT COUNT(*) as total FROM products'
    );
    const [returnsData] = await conn.query(
      'SELECT COUNT(*) as total FROM returns'
    );
    const [customersData] = await conn.query(
      'SELECT COUNT(*) as total FROM customers'
    );

    // Sales trend chart (monthly)
    const [salesTrend] = await conn.query(
      `SELECT 
        DATE_FORMAT(CURDATE() - INTERVAL DAY(CURDATE())-1 DAY + INTERVAL (n-1) MONTH, '%b') as month,
        COALESCE(SUM(CASE WHEN YEAR(mo.order_date) = YEAR(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) AND MONTH(mo.order_date) = MONTH(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) THEN mo.total_amount ELSE 0 END), 0) as liveSales,
        COALESCE(SUM(CASE WHEN YEAR(mo.order_date) = YEAR(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) AND MONTH(mo.order_date) = MONTH(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) THEN mo.total_amount ELSE 0 END), 0) as marketplaceSales
      FROM (
        SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
      ) nums
      LEFT JOIN marketplace_orders mo ON YEAR(mo.order_date) = YEAR(DATE_SUB(NOW(), INTERVAL (6-n) MONTH)) AND MONTH(mo.order_date) = MONTH(DATE_SUB(NOW(), INTERVAL (6-n) MONTH))
      GROUP BY n
      ORDER BY n`
    );

    // Marketplace comparison chart
    const [marketplaceComparison] = await conn.query(
      `SELECT p.name as platform, COALESCE(SUM(mo.total_amount), 0) as total
       FROM platforms p
       LEFT JOIN marketplace_orders mo ON p.id = mo.platform_id
       GROUP BY p.id, p.name`
    );

    // Stock summary
    const [stockSummary] = await conn.query(
      `SELECT category_name as category, COALESCE(SUM(stock_quantity), 0) as stock
       FROM product_categories pc
       LEFT JOIN products p ON pc.id = p.category_id
       GROUP BY pc.id, pc.category_name`
    );

    // Recent activities
    const [recentActivities] = await conn.query(
      `SELECT al.id, u.full_name as user_name, al.action, al.module, al.created_at
       FROM activity_logs al
       JOIN users u ON al.user_id = u.id
       ORDER BY al.created_at DESC
       LIMIT 10`
    );

    // Recent orders
    const [recentOrders] = await conn.query(
      `SELECT mo.id, mo.order_number, c.name as customer_name, p.name as platform_name, mo.total_amount
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
          totalMarketplaceSales: productsSalesData[0]?.total || 0,
          totalOrders: productsData[0]?.total || 0,
          totalBonusHost: 0,
          totalProductsSold: customersData[0]?.total || 0
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
      `SELECT COALESCE(SUM(lsa.total_revenue), 0) as total
       FROM live_schedules ls
       LEFT JOIN live_sales lsa ON ls.id = lsa.live_schedule_id
       WHERE ls.host_id = ?`,
      [hostId]
    );
    const [schedulesData] = await conn.query(
      'SELECT COUNT(*) as total FROM live_schedules WHERE host_id = ?',
      [hostId]
    );
    const [viewsData] = await conn.query(
      `SELECT COALESCE(SUM(lsa.total_views), 0) as total
       FROM live_schedules ls
       LEFT JOIN live_sales lsa ON ls.id = lsa.live_schedule_id
       WHERE ls.host_id = ?`,
      [hostId]
    );
    const [likesData] = await conn.query(
      `SELECT COALESCE(SUM(lsa.total_likes), 0) as total
       FROM live_schedules ls
       LEFT JOIN live_sales lsa ON ls.id = lsa.live_schedule_id
       WHERE ls.host_id = ?`,
      [hostId]
    );

    // Sales trend chart (monthly)
    const [salesTrend] = await conn.query(
      `SELECT 
        DATE_FORMAT(CURDATE() - INTERVAL DAY(CURDATE())-1 DAY + INTERVAL (n-1) MONTH, '%b') as month,
        COALESCE(SUM(CASE WHEN YEAR(ls.schedule_date) = YEAR(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) AND MONTH(ls.schedule_date) = MONTH(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) THEN lsa.total_revenue ELSE 0 END), 0) as liveSales,
        COALESCE(SUM(CASE WHEN YEAR(ls.schedule_date) = YEAR(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) AND MONTH(ls.schedule_date) = MONTH(DATE_SUB(NOW(), INTERVAL (5-n) MONTH)) THEN lsa.total_revenue ELSE 0 END), 0) as marketplaceSales
      FROM (
        SELECT 1 as n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
      ) nums
      LEFT JOIN live_schedules ls ON YEAR(ls.schedule_date) = YEAR(DATE_SUB(NOW(), INTERVAL (6-n) MONTH)) AND MONTH(ls.schedule_date) = MONTH(DATE_SUB(NOW(), INTERVAL (6-n) MONTH)) AND ls.host_id = ?
      LEFT JOIN live_sales lsa ON ls.id = lsa.live_schedule_id
      GROUP BY n
      ORDER BY n`,
      [hostId]
    );

    // Platform comparison
    const [marketplaceComparison] = await conn.query(
      `SELECT p.name as platform, COALESCE(SUM(lsa.total_revenue), 0) as total
       FROM platforms p
       LEFT JOIN live_schedules ls ON p.id = ls.platform_id AND ls.host_id = ?
       LEFT JOIN live_sales lsa ON ls.id = lsa.live_schedule_id
       GROUP BY p.id, p.name`,
      [hostId]
    );

    // Stock summary
    const [stockSummary] = await conn.query(
      `SELECT 'Total Schedules' as category, COUNT(*) as stock
       FROM live_schedules
       WHERE host_id = ?`,
      [hostId]
    );

    // Recent activities
    const [recentActivities] = await conn.query(
      `SELECT al.id, u.full_name as user_name, al.action, al.module, al.created_at
       FROM activity_logs al
       JOIN users u ON al.user_id = u.id
       WHERE u.id = ?
       ORDER BY al.created_at DESC
       LIMIT 10`,
      [hostId]
    );

    // Recent orders/sales
    const [recentOrders] = await conn.query(
      `SELECT lsa.id, ls.schedule_date as order_date, u.full_name as customer_name, p.name as platform_name, lsa.total_revenue as total_amount
       FROM live_schedules ls
       LEFT JOIN live_sales lsa ON ls.id = lsa.live_schedule_id
       LEFT JOIN users u ON ls.host_id = u.id
       LEFT JOIN platforms p ON ls.platform_id = p.id
       WHERE ls.host_id = ?
       ORDER BY ls.schedule_date DESC
       LIMIT 10`,
      [hostId]
    );

    conn.release();

    return res.status(200).json({
      success: true,
      data: {
        summary: {
          totalLiveSales: liveSalesData[0]?.total || 0,
          totalMarketplaceSales: liveSalesData[0]?.total || 0,
          totalOrders: schedulesData[0]?.total || 0,
          totalBonusHost: viewsData[0]?.total || 0,
          totalProductsSold: likesData[0]?.total || 0
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