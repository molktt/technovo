import { useState } from 'react';

export const useTableControls = (initial = {}) => {
  const [search, setSearch] = useState('');
  const [page, setPage] = useState(0);
  const [rowsPerPage, setRowsPerPage] = useState(initial.rowsPerPage || 10);
  const [sortBy, setSortBy] = useState(initial.sortBy || 'id');
  const [sortOrder, setSortOrder] = useState(initial.sortOrder || 'DESC');
  const [filters, setFilters] = useState(initial.filters || {});

  const handleSort = (column) => {
    if (sortBy === column) {
      setSortOrder(sortOrder === 'ASC' ? 'DESC' : 'ASC');
    } else {
      setSortBy(column);
      setSortOrder('ASC');
    }
  };

  const updateFilter = (key, value) => {
    setFilters((prev) => ({ ...prev, [key]: value }));
    setPage(0);
  };

  const queryParams = {
    search,
    page: page + 1,
    limit: rowsPerPage,
    sortBy,
    sortOrder,
    ...filters,
  };

  return {
    search,
    setSearch,
    page,
    setPage,
    rowsPerPage,
    setRowsPerPage,
    sortBy,
    sortOrder,
    handleSort,
    filters,
    updateFilter,
    queryParams,
  };
};

export const exportToCSV = (rows, columns, filename = 'export.csv') => {
  const header = columns.map((c) => c.label).join(',');
  const body = rows
    .map((row) =>
      columns
        .map((c) => {
          const val = c.render ? c.render(row) : row[c.field];
          const str = val == null ? '' : String(val).replace(/"/g, '""');
          return `"${str}"`;
        })
        .join(',')
    )
    .join('\n');

  const blob = new Blob([`${header}\n${body}`], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  link.href = URL.createObjectURL(blob);
  link.download = filename;
  link.click();
};
