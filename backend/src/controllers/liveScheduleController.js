const pool = require('../config/db');
const logActivity = require('../utils/activityLogger');
const { sendSuccess, sendError } = require('../utils/response');

const getLiveSchedules = async (req, res) => {
  try {
    const { search = '', host_id, platform_id, status, sortBy = 'schedule_date', sortOrder = 'DESC', page = 1, limit = 10 } = req.query;
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
      conditions.push('(ls.title LIKE ? OR u.name LIKE ? OR pl.name LIKE ?)');
      values.push(`%${search}%`, `%${search}%`, `%${search}%`);
    }
    if (platform_id && platform_id !== 'all') {
      conditions.push('ls.platform_id = ?');
      values.push(platform_id);
    }
    if (status && status !== 'all') {
      conditions.push('ls.status = ?');
      values.push(status);
    }

    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
    const order = sortOrder.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';
    const allowedSort = ['id', 'schedule_date', 'start_time', 'status', 'created_at'];
    const sort = allowedSort.includes(sortBy) ? sortBy : 'schedule_date';
    const offset = (Math.max(parseInt(page, 10), 1) - 1) * parseInt(limit, 10);

    const [rows] = await pool.query(
      `SELECT ls.*, u.name AS host_name, pl.name AS platform_name
       FROM live_schedules ls
       LEFT JOIN users u ON ls.host_id = u.id
       LEFT JOIN platforms pl ON ls.platform_id = pl.id
       ${where} ORDER BY ls.${sort} ${order} LIMIT ? OFFSET ?`,
      [...values, parseInt(limit, 10), offset]
    );

    const [[{ total }]] = await pool.query(
      `SELECT COUNT(*) AS total FROM live_schedules ls
       LEFT JOIN users u ON ls.host_id = u.id
       LEFT JOIN platforms pl ON ls.platform_id = pl.id ${where}`,
      values
    );

    return sendSuccess(res, { items: rows, total, page: parseInt(page, 10), limit: parseInt(limit, 10) });
  } catch (error) {
    console.error('Get schedules error:', error);
    return sendError(res, 'Failed to fetch schedules', 500);
  }
};

const createLiveSchedule = async (req, res) => {
  try {
    const { host_id, platform_id, title, schedule_date, start_time, end_time, status } = req.body;
    if (!host_id || !platform_id || !schedule_date || !start_time || !end_time) {
      return sendError(res, 'Required fields missing', 400);
    }

    const [result] = await pool.query(
      `INSERT INTO live_schedules (host_id, platform_id, title, schedule_date, start_time, end_time, status)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [host_id, platform_id, title || 'Live Session', schedule_date, start_time, end_time, status || 'scheduled']
    );

    await logActivity(req.user.id, 'CREATE', 'Live Schedules', `Created schedule for ${schedule_date}`);
    return sendSuccess(res, { id: result.insertId }, 'Schedule created successfully', 201);
  } catch (error) {
    return sendError(res, 'Failed to create schedule', 500);
  }
};

const updateLiveSchedule = async (req, res) => {
  try {
    const { host_id, platform_id, title, schedule_date, start_time, end_time, status } = req.body;
    const { id } = req.params;

    const [existing] = await pool.query('SELECT id FROM live_schedules WHERE id = ?', [id]);
    if (!existing.length) return sendError(res, 'Schedule not found', 404);

    await pool.query(
      `UPDATE live_schedules SET host_id=?, platform_id=?, title=?, schedule_date=?, start_time=?, end_time=?, status=? WHERE id=?`,
      [host_id, platform_id, title, schedule_date, start_time, end_time, status, id]
    );

    await logActivity(req.user.id, 'UPDATE', 'Live Schedules', `Updated schedule #${id}`);
    return sendSuccess(res, null, 'Schedule updated successfully');
  } catch (error) {
    return sendError(res, 'Failed to update schedule', 500);
  }
};

const deleteLiveSchedule = async (req, res) => {
  try {
    const [existing] = await pool.query('SELECT id FROM live_schedules WHERE id = ?', [req.params.id]);
    if (!existing.length) return sendError(res, 'Schedule not found', 404);

    await pool.query('DELETE FROM live_schedules WHERE id = ?', [req.params.id]);
    await logActivity(req.user.id, 'DELETE', 'Live Schedules', `Deleted schedule #${req.params.id}`);
    return sendSuccess(res, null, 'Schedule deleted successfully');
  } catch (error) {
    return sendError(res, 'Failed to delete schedule', 500);
  }
};

module.exports = { getLiveSchedules, createLiveSchedule, updateLiveSchedule, deleteLiveSchedule };
