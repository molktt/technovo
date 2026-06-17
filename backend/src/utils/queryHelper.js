const buildListQuery = (baseQuery, countQuery, params, query) => {
  const {
    search = '',
    sortBy = 'id',
    sortOrder = 'DESC',
    page = 1,
    limit = 10,
    ...filters
  } = query;

  let whereClause = '';
  const values = [...params];
  const conditions = [];

  if (search) {
    conditions.push('(1=1)');
  }

  Object.entries(filters).forEach(([key, value]) => {
    if (value !== undefined && value !== '' && value !== 'all') {
      conditions.push(`${key} = ?`);
      values.push(value);
    }
  });

  if (conditions.length > 0) {
    whereClause = ` WHERE ${conditions.join(' AND ')}`;
  }

  const allowedSortOrders = ['ASC', 'DESC'];
  const order = allowedSortOrders.includes(String(sortOrder).toUpperCase())
    ? String(sortOrder).toUpperCase()
    : 'DESC';

  const offset = (Math.max(parseInt(page, 10) || 1, 1) - 1) * (parseInt(limit, 10) || 10);
  const pageLimit = parseInt(limit, 10) || 10;

  const dataQuery = `${baseQuery}${whereClause} ORDER BY ${sortBy} ${order} LIMIT ? OFFSET ?`;
  const totalQuery = `${countQuery}${whereClause}`;

  return {
    dataQuery,
    totalQuery,
    values: [...values, pageLimit, offset],
    countValues: values,
  };
};

module.exports = { buildListQuery };
